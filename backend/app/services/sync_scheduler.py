"""
Servicio de Automatización de Sincronización con APScheduler:
- Ejecuta sincronizaciones periódicas de Facebook e Instagram en segundo plano.
- Respeta límites de velocidad (Rate Limits) y respuestas HTTP 429 de Meta Graph API.
- Implementa reintentos con retroceso exponencial (backoff).
- Previene ejecuciones duplicadas generadas por el reloader de Flask (WERKZEUG_RUN_MAIN).
- Evita concurrencia entre ejecuciones automáticas y manuales.
- Registra el resultado de cada ciclo en dbo.accion_agente.
- NUNCA expone ni registra tokens de acceso en logs.
- Arquitectura preparada para ejecución embebida o como proceso independiente.
"""
from __future__ import annotations

import logging
import os
import time
from datetime import datetime
from typing import Any
from flask import Flask

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger

from app.agents.buyer_coordinator import BuyerCoordinator, SincronizacionEnCursoError

logger = logging.getLogger("sync_scheduler")

# Instancia global del scheduler y del coordinador
_scheduler: BackgroundScheduler | None = None
_coordinator: BuyerCoordinator = BuyerCoordinator()
_app_ref: Flask | None = None
_scheduler_state: dict[str, Any] = {
    "enabled": False,
    "interval_minutes": 10,
    "is_running": False,
    "last_run": None,
    "last_result": None,
    "total_runs": 0,
    "failed_runs": 0,
}


def _ejecutar_ciclo_sincronizacion(app: Flask, plataforma: str = "todas") -> dict[str, Any]:
    """
    Función de trabajo invocada por el scheduler o manualmente.
    Se ejecuta dentro del contexto de aplicación de Flask.
    """
    global _scheduler_state

    _scheduler_state["last_run"] = datetime.utcnow().isoformat()
    _scheduler_state["total_runs"] += 1

    max_intentos = 2
    backoff_segundos = 5

    with app.app_context():
        for intento in range(1, max_intentos + 1):
            try:
                logger.info(
                    "[Scheduler] Iniciando ciclo de sincronización automática (intento %d/%d)...",
                    intento,
                    max_intentos,
                )
                resultado = _coordinator.sincronizar(plataforma=plataforma, clasificar_comentarios=True)
                _scheduler_state["last_result"] = {
                    "success": resultado.get("success", False),
                    "estado": resultado.get("estado"),
                    "resumen": resultado.get("resumen_total"),
                    "fecha": resultado.get("fecha_ejecucion"),
                }
                logger.info(
                    "[Scheduler] Ciclo completado exitosamente. Estado: %s",
                    resultado.get("estado"),
                )
                return resultado

            except SincronizacionEnCursoError as exc:
                logger.warning("[Scheduler] Ciclo omitido: otra sincronización sigue en ejecución.")
                return {
                    "success": False,
                    "error": str(exc),
                    "omitido_por_concurrencia": True,
                }

            except Exception as exc:
                error_msg = str(exc)
                # Detección de rate limit 429
                is_rate_limit = "429" in error_msg or "rate limit" in error_msg.lower() or "too many requests" in error_msg.lower()

                if is_rate_limit:
                    logger.warning(
                        "[Scheduler] Límite de solicitudes de Meta alcanzado (429). Esperando antes de reintentar..."
                    )
                    time.sleep(backoff_segundos * 2)
                else:
                    logger.error(
                        "[Scheduler] Error en intento %d/%d: %s",
                        intento,
                        max_intentos,
                        error_msg,
                        exc_info=True,
                    )

                if intento < max_intentos:
                    time.sleep(backoff_segundos * intento)
                else:
                    _scheduler_state["failed_runs"] += 1
                    _scheduler_state["last_result"] = {
                        "success": False,
                        "error": error_msg,
                        "fecha": datetime.utcnow().isoformat(),
                    }
                    return {"success": False, "error": error_msg}

    return {"success": False, "error": "Ciclo no ejecutado."}


class SyncSchedulerService:
    """
    Controlador del planificador de sincronización automática.
    """

    @classmethod
    def get_coordinator(cls) -> BuyerCoordinator:
        return _coordinator

    @classmethod
    def init_app(cls, app: Flask) -> None:
        """
        Inicializa el planificador con la configuración de Flask.
        Previene ejecuciones duplicadas generadas por el reloader de Werkzeug.
        """
        global _scheduler, _app_ref, _scheduler_state

        _app_ref = app

        enabled = app.config.get("META_SYNC_ENABLED", False)
        interval = app.config.get("META_SYNC_INTERVAL_MINUTES", 10)

        _scheduler_state["enabled"] = enabled
        _scheduler_state["interval_minutes"] = interval

        # Si el scheduler ya fue instanciado, no duplicar
        if _scheduler is not None:
            return

        # Prevenir ejecución dual provocada por el debug reloader de Flask
        is_debug = app.debug or os.environ.get("FLASK_ENV") == "development"
        is_reloader_child = os.environ.get("WERKZEUG_RUN_MAIN") == "true"

        if is_debug and not is_reloader_child and os.environ.get("FLASK_RUN_FROM_CLI") == "true":
            logger.info("[Scheduler] Proceso padre de reloader detectado. Scheduler se activará en el proceso hijo.")
            return

        _scheduler = BackgroundScheduler(daemon=True)

        trigger = IntervalTrigger(minutes=max(1, interval))
        _scheduler.add_job(
            func=_ejecutar_ciclo_sincronizacion,
            trigger=trigger,
            args=[app, "todas"],
            id="job_meta_sync_periodico",
            name="Sincronización Periódica Meta (FB e IG)",
            replace_existing=True,
            coalesce=True,  # Si una ejecución se atrasa, no disparar en avalancha
            max_instances=1,  # Estricto: jamás dos instancias simultáneas de este job
        )

        if enabled:
            cls.start()
        else:
            logger.info(
                "[Scheduler] Planificador configurado pero DESACTIVADO (META_SYNC_ENABLED=false, intervalo=%d min).",
                interval,
            )

    @classmethod
    def start(cls) -> bool:
        """Inicia el background scheduler si no está corriendo."""
        global _scheduler, _scheduler_state
        if _scheduler is None:
            logger.warning("[Scheduler] No se puede iniciar: scheduler no inicializado.")
            return False

        if not _scheduler.running:
            _scheduler.start()
            _scheduler_state["is_running"] = True
            _scheduler_state["enabled"] = True
            logger.info(
                "[Scheduler] Servicio de sincronización automática INICIADO (intervalo: %d min).",
                _scheduler_state["interval_minutes"],
            )
            return True
        return True

    @classmethod
    def stop(cls) -> bool:
        """Detiene o pausa el scheduler."""
        global _scheduler, _scheduler_state
        if _scheduler is not None and _scheduler.running:
            _scheduler.shutdown(wait=False)
            _scheduler = None
            _scheduler_state["is_running"] = False
            _scheduler_state["enabled"] = False
            logger.info("[Scheduler] Servicio de sincronización automática DETENIDO.")
            return True
        return False

    @classmethod
    def get_status(cls) -> dict[str, Any]:
        """Retorna el estado operativo completo del planificador."""
        global _scheduler, _scheduler_state, _coordinator

        is_running = _scheduler is not None and _scheduler.running
        job_info = None

        if is_running and _scheduler:
            job = _scheduler.get_job("job_meta_sync_periodico")
            if job:
                job_info = {
                    "id": job.id,
                    "name": job.name,
                    "proxima_ejecucion": job.next_run_time.isoformat() if job.next_run_time else None,
                }

        coord_status = _coordinator.get_status()

        return {
            "scheduler_activo": is_running,
            "habilitado_config": _scheduler_state["enabled"],
            "intervalo_minutos": _scheduler_state["interval_minutes"],
            "total_ejecuciones": _scheduler_state["total_runs"],
            "ejecuciones_fallidas": _scheduler_state["failed_runs"],
            "ultima_ejecucion": _scheduler_state["last_run"],
            "ultimo_resultado": _scheduler_state["last_result"],
            "trabajo_programado": job_info,
            "coordinador": coord_status.get("coordinador"),
        }

    @classmethod
    def ejecutar_manual(cls, plataforma: str = "todas") -> dict[str, Any]:
        """
        Dispara una sincronización manual inmediata a través del coordinador.
        """
        global _app_ref
        if _app_ref is None:
            # Si se invoca sin app_ref, usar el coordinador directamente
            return _coordinator.sincronizar(plataforma=plataforma, clasificar_comentarios=True)

        return _ejecutar_ciclo_sincronizacion(_app_ref, plataforma=plataforma)
