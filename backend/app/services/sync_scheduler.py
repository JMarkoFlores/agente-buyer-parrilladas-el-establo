"""
Servicio de Automatización de Sincronización con APScheduler:
- Ejecuta sincronizaciones periódicas de Facebook e Instagram en segundo plano.
- Soporta configuración en segundos (META_SYNC_INTERVAL_SECONDS) y minutos (META_SYNC_INTERVAL_MINUTES).
- Prioriza segundos sobre minutos e informa cuál configuración está activa.
- Respeta límites de velocidad (Rate Limits / HTTP 429) de Meta Graph API reduciendo temporalmente la frecuencia.
- Implementa reintentos con retroceso exponencial (backoff).
- Previene ejecuciones duplicadas generadas por el reloader de Flask (WERKZEUG_RUN_MAIN).
- Evita concurrencia entre ejecuciones automáticas y manuales (max_instances=1, coalesce=True).
- Registra la duración de cada sincronización y el resultado en dbo.accion_agente.
- NUNCA expone ni registra tokens de acceso en logs.
- Arquitectura preparada para ejecución embebida o como proceso independiente en contenedor.
"""
from __future__ import annotations

import logging
import os
import time
from datetime import datetime, timedelta
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

# Variables de control de Rate Limit y Backoff dinámico
_rate_limit_cooldown_until: datetime | None = None
_rate_limit_backoff_seconds: int = 60  # Pausa inicial al detectar Rate Limit

_scheduler_state: dict[str, Any] = {
    "enabled": False,
    "interval_seconds": 10,
    "interval_minutes": 0.17,
    "intervalo_activo": "10 segundos",
    "origen_configuracion": "DEFAULT",
    "ambas_variables_presentes": False,
    "is_running": False,
    "last_run": None,
    "last_result": None,
    "last_duration_seconds": None,
    "total_runs": 0,
    "failed_runs": 0,
    "rate_limit_cooldown_activo": False,
    "rate_limit_cooldown_hasta": None,
}


def _ejecutar_ciclo_sincronizacion(app: Flask, plataforma: str = "todas") -> dict[str, Any]:
    """
    Función de trabajo invocada por el scheduler o manualmente.
    Se ejecuta dentro del contexto de aplicación de Flask.
    Registra duración y gestiona Rate Limits con backoff.
    """
    global _scheduler_state, _rate_limit_cooldown_until, _rate_limit_backoff_seconds

    now = datetime.utcnow()

    # 1. Verificar si nos encontramos en periodo de enfriamiento (cooldown) por Rate Limit 429 previo
    if _rate_limit_cooldown_until and now < _rate_limit_cooldown_until:
        restante = max(1, int((_rate_limit_cooldown_until - now).total_seconds()))
        logger.warning(
            "[Scheduler] Ciclo omitido: en periodo de enfriamiento temporal por límite de Meta (Rate Limit / 429). Restan %d segundos.",
            restante,
        )
        return {
            "success": False,
            "omitido_por_rate_limit": True,
            "segundos_restantes": restante,
        }

    _scheduler_state["last_run"] = now.isoformat()
    _scheduler_state["total_runs"] += 1
    t_inicio = time.time()

    max_intentos = 2
    backoff_segundos = 3

    with app.app_context():
        for intento in range(1, max_intentos + 1):
            try:
                logger.info(
                    "[Scheduler] Iniciando ciclo de sincronización automática (intento %d/%d)...",
                    intento,
                    max_intentos,
                )
                resultado = _coordinator.sincronizar(plataforma=plataforma, clasificar_comentarios=True)
                duracion = round(time.time() - t_inicio, 2)

                # Restablecer enfriamiento tras éxito
                _rate_limit_backoff_seconds = 60
                _rate_limit_cooldown_until = None
                _scheduler_state["rate_limit_cooldown_activo"] = False
                _scheduler_state["rate_limit_cooldown_hasta"] = None
                _scheduler_state["last_duration_seconds"] = duracion

                _scheduler_state["last_result"] = {
                    "success": resultado.get("success", False),
                    "estado": resultado.get("estado"),
                    "resumen": resultado.get("resumen_total"),
                    "fecha": resultado.get("fecha_ejecucion"),
                    "duracion_segundos": duracion,
                }

                logger.info(
                    "[Scheduler] Ciclo completado en %.2fs. Estado: %s. Nuevos -> Pubs: %d, Coms: %d, BUYERS: %d.",
                    duracion,
                    resultado.get("estado"),
                    resultado.get("resumen_total", {}).get("publicaciones", {}).get("nuevos", 0),
                    resultado.get("resumen_total", {}).get("comentarios", {}).get("nuevos", 0),
                    resultado.get("resumen_total", {}).get("buyers", {}).get("nuevos", 0),
                )
                return resultado

            except SincronizacionEnCursoError as exc:
                duracion = round(time.time() - t_inicio, 2)
                logger.warning(
                    "[Scheduler] Ciclo omitido tras %.2fs: otra sincronización sigue en ejecución.",
                    duracion,
                )
                return {
                    "success": False,
                    "error": str(exc),
                    "omitido_por_concurrencia": True,
                    "duracion_segundos": duracion,
                }

            except Exception as exc:
                duracion = round(time.time() - t_inicio, 2)
                error_msg = str(exc)

                # Detección exhaustiva de Rate Limit (HTTP 429 / Cuota excedida)
                is_rate_limit = (
                    "429" in error_msg
                    or "rate limit" in error_msg.lower()
                    or "too many requests" in error_msg.lower()
                    or "user request limit reached" in error_msg.lower()
                    or "calls to this api have exceeded" in error_msg.lower()
                )

                if is_rate_limit:
                    _rate_limit_cooldown_until = datetime.utcnow() + timedelta(seconds=_rate_limit_backoff_seconds)
                    _scheduler_state["rate_limit_cooldown_activo"] = True
                    _scheduler_state["rate_limit_cooldown_hasta"] = _rate_limit_cooldown_until.isoformat()
                    logger.warning(
                        "[Scheduler] Límite de solicitudes de Meta alcanzado (429 / Rate Limit). Frecuencia reducida temporalmente: pausando sincronización por %d segundos.",
                        _rate_limit_backoff_seconds,
                    )
                    # Retroceso exponencial para subsiguientes errores 429
                    _rate_limit_backoff_seconds = min(300, _rate_limit_backoff_seconds * 2)
                    _scheduler_state["failed_runs"] += 1
                    _scheduler_state["last_duration_seconds"] = duracion
                    _scheduler_state["last_result"] = {
                        "success": False,
                        "error": "Meta Rate Limit (429). Enfriamiento activado.",
                        "fecha": datetime.utcnow().isoformat(),
                        "duracion_segundos": duracion,
                    }
                    return {"success": False, "error": error_msg, "duracion_segundos": duracion}

                logger.error(
                    "[Scheduler] Error en intento %d/%d (duración %.2fs): %s",
                    intento,
                    max_intentos,
                    duracion,
                    error_msg,
                    exc_info=True,
                )

                if intento < max_intentos:
                    time.sleep(backoff_segundos * intento)
                else:
                    _scheduler_state["failed_runs"] += 1
                    _scheduler_state["last_duration_seconds"] = duracion
                    _scheduler_state["last_result"] = {
                        "success": False,
                        "error": error_msg,
                        "fecha": datetime.utcnow().isoformat(),
                        "duracion_segundos": duracion,
                    }
                    return {"success": False, "error": error_msg, "duracion_segundos": duracion}

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
        Soporta META_SYNC_INTERVAL_SECONDS con fallback a META_SYNC_INTERVAL_MINUTES.
        Previene ejecuciones duplicadas generadas por el reloader de Werkzeug.
        """
        global _scheduler, _app_ref, _scheduler_state

        _app_ref = app

        enabled = app.config.get("META_SYNC_ENABLED", False)

        # 1. Determinar intervalo en segundos y minutos
        sec_cfg = app.config.get("META_SYNC_INTERVAL_SECONDS")
        min_cfg = app.config.get("META_SYNC_INTERVAL_MINUTES")
        origen_cfg = app.config.get("META_SYNC_INTERVAL_ORIGEN", "DEFAULT")

        # Comprobar presencia de ambas variables en el entorno
        env_sec = os.getenv("META_SYNC_INTERVAL_SECONDS")
        env_min = os.getenv("META_SYNC_INTERVAL_MINUTES")
        ambas_presentes = bool(env_sec and env_sec.strip() and env_min and env_min.strip())

        if sec_cfg is not None:
            intervalo_segundos = max(1, int(sec_cfg))
        elif min_cfg is not None:
            intervalo_segundos = max(1, int(min_cfg * 60))
        else:
            intervalo_segundos = 10

        intervalo_minutos = round(intervalo_segundos / 60.0, 2)
        intervalo_activo_str = f"{intervalo_segundos} segundos" if intervalo_segundos < 60 else f"{intervalo_minutos} minutos ({intervalo_segundos}s)"

        _scheduler_state["enabled"] = enabled
        _scheduler_state["interval_seconds"] = intervalo_segundos
        _scheduler_state["interval_minutes"] = intervalo_minutos
        _scheduler_state["intervalo_activo"] = intervalo_activo_str
        _scheduler_state["origen_configuracion"] = origen_cfg
        _scheduler_state["ambas_variables_presentes"] = ambas_presentes

        # Reportar en logs cuál variable tiene precedencia
        if ambas_presentes:
            logger.info(
                "[Scheduler] Ambas variables detectadas en entorno: META_SYNC_INTERVAL_SECONDS=%s y META_SYNC_INTERVAL_MINUTES=%s. Prioridad aplicada: activo en %s (%s).",
                env_sec,
                env_min,
                intervalo_activo_str,
                origen_cfg,
            )
        else:
            logger.info(
                "[Scheduler] Intervalo de sincronización configurado en %s (origen: %s).",
                intervalo_activo_str,
                origen_cfg,
            )

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

        # Trigger en segundos exactos (soporta 10s, 30s, 60s, etc.)
        trigger = IntervalTrigger(seconds=intervalo_segundos)
        _scheduler.add_job(
            func=_ejecutar_ciclo_sincronizacion,
            trigger=trigger,
            args=[app, "todas"],
            id="job_meta_sync_periodico",
            name=f"Sincronización Periódica Meta (cada {intervalo_segundos}s)",
            replace_existing=True,
            coalesce=True,  # Si una ejecución se atrasa, no disparar en avalancha
            max_instances=1,  # Estricto: jamás dos instancias simultáneas de este job
        )

        if enabled:
            cls.start()
        else:
            logger.info(
                "[Scheduler] Planificador configurado pero DESACTIVADO (META_SYNC_ENABLED=false, intervalo: %s).",
                intervalo_activo_str,
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
                "[Scheduler] Servicio de sincronización automática INICIADO (intervalo activo: %s).",
                _scheduler_state["intervalo_activo"],
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
            "intervalo_segundos": _scheduler_state["interval_seconds"],
            "intervalo_minutos": _scheduler_state["interval_minutes"],
            "intervalo_activo": _scheduler_state["intervalo_activo"],
            "origen_configuracion": _scheduler_state["origen_configuracion"],
            "ambas_variables_presentes": _scheduler_state["ambas_variables_presentes"],
            "total_ejecuciones": _scheduler_state["total_runs"],
            "ejecuciones_fallidas": _scheduler_state["failed_runs"],
            "ultima_ejecucion": _scheduler_state["last_run"],
            "ultima_duracion_segundos": _scheduler_state["last_duration_seconds"],
            "ultimo_resultado": _scheduler_state["last_result"],
            "en_enfriamiento_rate_limit": _scheduler_state["rate_limit_cooldown_activo"],
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
            return _coordinator.sincronizar(plataforma=plataforma, clasificar_comentarios=True)

        return _ejecutar_ciclo_sincronizacion(_app_ref, plataforma=plataforma)
