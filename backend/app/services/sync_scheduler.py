"""
Servicio de Automatización de Sincronización con APScheduler:
- Ejecuta sincronizaciones periódicas de Facebook e Instagram en segundo plano cada 60 segundos.
- Soporta configuración en segundos (META_SYNC_INTERVAL_SECONDS) y minutos (META_SYNC_INTERVAL_MINUTES).
- Prioriza segundos sobre minutos e informa cuál configuración está activa.
- Previene estrictamente ejecuciones duplicadas generadas por el Werkzeug Debug Reloader (WERKZEUG_RUN_MAIN).
- Implementa bloqueo de instancia única inter-proceso (FileLock / SQL Server AppLock).
- Evita concurrencia entre ejecuciones automáticas y manuales (max_instances=1, coalesce=True).
- Respeta límites de velocidad (Rate Limits / HTTP 429) de Meta Graph API reduciendo temporalmente la frecuencia.
- Implementa reintentos con retroceso exponencial (backoff).
- Registra duración y resultado en dbo.accion_agente.
- NUNCA expone ni registra tokens de acceso en logs.
- Arquitectura preparada para desarrollo local y producción (standalone worker o proceso independiente).
"""
from __future__ import annotations

import atexit
import logging
import os
import tempfile
import time
from datetime import datetime, timedelta
from typing import Any
from flask import Flask

from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.interval import IntervalTrigger

from app.agents.buyer_coordinator import BuyerCoordinator, SincronizacionEnCursoError

logger = logging.getLogger("sync_scheduler")


# ==============================================================================
# MECANISMOS DE BLOQUEO DE INSTANCIA ÚNICA (LEADER ELECTION)
# ==============================================================================

class BaseSchedulerLock:
    """Interfaz base para el bloqueo de instancia única del planificador."""

    def acquire(self) -> bool:
        raise NotImplementedError

    def release(self) -> None:
        raise NotImplementedError

    def description(self) -> str:
        raise NotImplementedError


class FileProcessLock(BaseSchedulerLock):
    """
    Bloqueo inter-proceso a nivel de sistema operativo mediante descriptor exclusivo.
    - Windows: msvcrt.locking con LK_NBLCK (bloqueo no bloqueante).
    - Linux / macOS: fcntl.flock con LOCK_EX | LOCK_NB.
    - Si el proceso finaliza, recarga o se interrumpe, el SO libera el archivo automáticamente.
    """

    def __init__(self, lock_file_path: str | None = None):
        if not lock_file_path:
            lock_file_path = os.path.join(tempfile.gettempdir(), "establo_buyer_sync_scheduler.lock")
        self.lock_file_path = lock_file_path
        self._file = None
        self._acquired = False

    def acquire(self) -> bool:
        if self._acquired:
            return True
        try:
            self._file = open(self.lock_file_path, "a+")
            self._file.seek(0)
            if os.name == "nt":
                import msvcrt
                msvcrt.locking(self._file.fileno(), msvcrt.LK_NBLCK, 1)
            else:
                import fcntl
                fcntl.flock(self._file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)

            self._file.seek(0)
            self._file.truncate()
            self._file.write(f"pid={os.getpid()}\ninicio={datetime.utcnow().isoformat()}\n")
            self._file.flush()
            self._acquired = True
            return True
        except (BlockingIOError, OSError, PermissionError, IOError):
            if self._file:
                try:
                    self._file.close()
                except Exception:
                    pass
                self._file = None
            self._acquired = False
            return False

    def release(self) -> None:
        if not self._acquired or not self._file:
            return
        try:
            if os.name == "nt":
                import msvcrt
                self._file.seek(0)
                msvcrt.locking(self._file.fileno(), msvcrt.LK_UNLCK, 1)
            else:
                import fcntl
                fcntl.flock(self._file.fileno(), fcntl.LOCK_UN)
        except Exception:
            pass
        try:
            self._file.close()
        except Exception:
            pass
        self._file = None
        self._acquired = False

    def description(self) -> str:
        return f"FileLock({self.lock_file_path})"


class SqlServerDistributedLock(BaseSchedulerLock):
    """
    Bloqueo distribuido en SQL Server mediante sp_getapplock.
    Permite garantizar una sola instancia del scheduler en clusters con múltiples contenedores.
    """

    def __init__(self, resource_name: str = "AgenteBuyer_SyncScheduler_Lock"):
        self.resource_name = resource_name
        self._connection = None
        self._acquired = False

    def acquire(self) -> bool:
        if self._acquired:
            return True
        try:
            from app.extensions import db
            conn = db.engine.raw_connection()
            cur = conn.cursor()
            cur.execute("""
                DECLARE @res int;
                EXEC @res = sp_getapplock 
                    @Resource = ?, 
                    @LockMode = 'Exclusive', 
                    @LockOwner = 'Session', 
                    @LockTimeout = 0;
                SELECT @res;
            """, (self.resource_name,))
            row = cur.fetchone()
            if row and row[0] is not None and row[0] >= 0:
                self._connection = conn
                self._acquired = True
                return True
            else:
                conn.close()
                self._acquired = False
                return False
        except Exception as exc:
            logger.warning("[SchedulerLock] No se pudo adquirir bloqueo en SQL Server: %s", exc)
            self._acquired = False
            return False

    def release(self) -> None:
        if not self._acquired or not self._connection:
            return
        try:
            cur = self._connection.cursor()
            cur.execute("EXEC sp_releaseapplock @Resource = ?, @LockOwner = 'Session';", (self.resource_name,))
            self._connection.close()
        except Exception:
            pass
        self._connection = None
        self._acquired = False

    def description(self) -> str:
        return f"SqlServerAppLock({self.resource_name})"


class NoOpLock(BaseSchedulerLock):
    """Bloqueo pasante para entornos de prueba."""

    def acquire(self) -> bool:
        return True

    def release(self) -> None:
        pass

    def description(self) -> str:
        return "NoOpLock"


# ==============================================================================
# ESTADO GLOBAL DEL PLANIFICADOR
# ==============================================================================

_scheduler: BackgroundScheduler | None = None
_coordinator: BuyerCoordinator = BuyerCoordinator()
_app_ref: Flask | None = None
_lock_instance: BaseSchedulerLock | None = None

# Variables de control de Rate Limit y Backoff dinámico
_rate_limit_cooldown_until: datetime | None = None
_rate_limit_backoff_seconds: int = 60

_scheduler_state: dict[str, Any] = {
    "enabled": False,
    "interval_seconds": 60,
    "interval_minutes": 1.0,
    "intervalo_activo": "1.0 minutos (60s)",
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
    "pid": os.getpid(),
    "es_lider": False,
    "modo_proceso": "no_inicializado",
    "tipo_bloqueo": "archivo",
    "bloqueo_adquirido": False,
    "instancia_unica_confirmada": False,
}


def _ejecutar_ciclo_sincronizacion(app: Flask, plataforma: str = "todas") -> dict[str, Any]:
    """
    Función de trabajo invocada periódicamente por APScheduler.
    Se ejecuta dentro del contexto de aplicación de Flask.
    Registra duración y gestiona Rate Limits con retroceso exponencial.
    """
    global _scheduler_state, _rate_limit_cooldown_until, _rate_limit_backoff_seconds

    now = datetime.utcnow()

    # 1. Verificar si nos encontramos en periodo de enfriamiento (cooldown) por Rate Limit 429
    if _rate_limit_cooldown_until and now < _rate_limit_cooldown_until:
        restante = max(1, int((_rate_limit_cooldown_until - now).total_seconds()))
        logger.warning(
            "[Scheduler] [PID %d] Ciclo omitido: en enfriamiento temporal por límite de Meta (Rate Limit / 429). Restan %d segundos.",
            os.getpid(),
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
                    "[Scheduler] [PID %d] Iniciando ciclo de sincronización automática (intento %d/%d)...",
                    os.getpid(),
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
                    "[Scheduler] [PID %d] Ciclo completado en %.2fs. Estado: %s. Nuevos -> Pubs: %d, Coms: %d, BUYERS: %d.",
                    os.getpid(),
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
                    "[Scheduler] [PID %d] Ciclo omitido tras %.2fs: otra sincronización sigue en ejecución.",
                    os.getpid(),
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

                # Detección de Rate Limit (HTTP 429)
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
                        "[Scheduler] [PID %d] Límite de solicitudes de Meta alcanzado (429). Frecuencia reducida temporalmente: pausando sincronización por %d segundos.",
                        os.getpid(),
                        _rate_limit_backoff_seconds,
                    )
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
                    "[Scheduler] [PID %d] Error en intento %d/%d (duración %.2fs): %s",
                    os.getpid(),
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
    Garantiza una única instancia activa del scheduler y coordina ejecuciones periódicas de 60 segundos.
    """

    @classmethod
    def get_coordinator(cls) -> BuyerCoordinator:
        return _coordinator

    @classmethod
    def get_lock(cls) -> BaseSchedulerLock:
        """Obtiene o crea la instancia de bloqueo configurada."""
        global _lock_instance
        if _lock_instance is None:
            lock_type = os.getenv("SCHEDULER_LOCK_TYPE", "file").strip().lower()
            if lock_type == "sql_server":
                _lock_instance = SqlServerDistributedLock()
            elif lock_type == "none":
                _lock_instance = NoOpLock()
            else:
                lock_path = os.getenv("SCHEDULER_LOCK_FILE")
                _lock_instance = FileProcessLock(lock_path)
            atexit.register(cls._cleanup_on_exit)
        return _lock_instance

    @classmethod
    def _cleanup_on_exit(cls) -> None:
        """Gancho de atexit para liberar el bloqueo y detener el scheduler al salir."""
        cls.stop()

    @classmethod
    def reset_for_testing(cls) -> None:
        """Restablece el estado global para pruebas automatizadas."""
        global _scheduler, _app_ref, _lock_instance, _scheduler_state
        cls.stop()
        if _lock_instance:
            _lock_instance.release()
            _lock_instance = None
        _scheduler = None
        _app_ref = None
        _scheduler_state["enabled"] = False
        _scheduler_state["is_running"] = False
        _scheduler_state["es_lider"] = False
        _scheduler_state["bloqueo_adquirido"] = False
        _scheduler_state["modo_proceso"] = "no_inicializado"
        _scheduler_state["instancia_unica_confirmada"] = False

    @classmethod
    def init_app(cls, app: Flask, force_leader: bool = False) -> None:
        """
        Inicializa el planificador con la configuración de Flask.
        Previene duplicación generada por el Werkzeug Debug Reloader y bloquea instancias concurrentes.
        """
        global _scheduler, _app_ref, _scheduler_state

        _app_ref = app
        enabled = app.config.get("META_SYNC_ENABLED", False)

        # 1. Determinar intervalo en segundos y minutos (prioridad para segundos)
        sec_cfg = app.config.get("META_SYNC_INTERVAL_SECONDS")
        min_cfg = app.config.get("META_SYNC_INTERVAL_MINUTES")
        origen_cfg = app.config.get("META_SYNC_INTERVAL_ORIGEN", "DEFAULT")

        env_sec = os.getenv("META_SYNC_INTERVAL_SECONDS")
        env_min = os.getenv("META_SYNC_INTERVAL_MINUTES")
        ambas_presentes = bool(env_sec and env_sec.strip() and env_min and env_min.strip())

        if sec_cfg is not None:
            intervalo_segundos = max(1, int(sec_cfg))
        elif min_cfg is not None:
            intervalo_segundos = max(1, int(min_cfg * 60))
        else:
            intervalo_segundos = 60

        intervalo_minutos = round(intervalo_segundos / 60.0, 2)
        intervalo_activo_str = f"{intervalo_segundos} segundos" if intervalo_segundos < 60 else f"{intervalo_minutos} minutos ({intervalo_segundos}s)"

        _scheduler_state["enabled"] = enabled
        _scheduler_state["interval_seconds"] = intervalo_segundos
        _scheduler_state["interval_minutes"] = intervalo_minutos
        _scheduler_state["intervalo_activo"] = intervalo_activo_str
        _scheduler_state["origen_configuracion"] = origen_cfg
        _scheduler_state["ambas_variables_presentes"] = ambas_presentes
        _scheduler_state["pid"] = os.getpid()

        # 2. Verificar modo Standalone (ejecución en proceso dedicado en producción)
        embedded_allowed = str(os.getenv("META_SYNC_SCHEDULER_EMBEDDED", "true")).strip().lower() in ("true", "1", "yes")
        standalone_active = str(os.getenv("SCHEDULER_STANDALONE", "false")).strip().lower() in ("true", "1", "yes")
        if (not embedded_allowed or standalone_active) and not force_leader:
            logger.info(
                "[Scheduler] [PID %d] Modo Standalone/Externo activo. Omitiendo inicio del scheduler embebido en servidor web.",
                os.getpid(),
            )
            _scheduler_state["modo_proceso"] = "standalone_externo"
            _scheduler_state["es_lider"] = False
            return

        # 3. Prevenir ejecución dual provocada por el debug reloader de Flask (Werkzeug)
        is_debug = bool(
            app.debug
            or app.config.get("DEBUG")
            or os.environ.get("FLASK_ENV") == "development"
            or os.environ.get("FLASK_DEBUG") == "1"
        )
        is_reloader_child = os.environ.get("WERKZEUG_RUN_MAIN") == "true"

        # En modo debug con reloader, el proceso padre es solo monitor de archivos.
        # APScheduler DEBE inicializarse únicamente en el proceso hijo (WERKZEUG_RUN_MAIN='true').
        if is_debug and not is_reloader_child and not force_leader:
            logger.info(
                "[Scheduler] [PID %d] Proceso monitor de Flask Debug Reloader detectado. "
                "Omitiendo inicio de APScheduler en este proceso; se activará exclusivamente "
                "en el proceso hijo de servicio (WERKZEUG_RUN_MAIN=true).",
                os.getpid(),
            )
            _scheduler_state["modo_proceso"] = "monitor_padre_reloader"
            _scheduler_state["es_lider"] = False
            return

        # Si el scheduler ya fue instanciado en este proceso, no duplicar
        if _scheduler is not None:
            logger.debug("[Scheduler] [PID %d] Scheduler ya instanciado en este proceso. Omitiendo reinicialización.", os.getpid())
            return

        # 4. Adquirir bloqueo inter-proceso / distribuido de instancia única
        lock = cls.get_lock()
        lock_adquirido = lock.acquire()
        _scheduler_state["tipo_bloqueo"] = os.getenv("SCHEDULER_LOCK_TYPE", "file").strip().lower()
        _scheduler_state["bloqueo_adquirido"] = lock_adquirido

        if not lock_adquirido and not force_leader:
            logger.warning(
                "[Scheduler] [PID %d] No se pudo obtener el bloqueo de instancia única (%s). "
                "Otra instancia del scheduler ya se encuentra activa y liderando. "
                "APScheduler no se iniciará en este worker secundario para prevenir duplicación.",
                os.getpid(),
                lock.description(),
            )
            _scheduler_state["modo_proceso"] = "worker_secundario"
            _scheduler_state["es_lider"] = False
            return

        # 5. Instancia Líder confirmada: configurar APScheduler
        modo_proceso = "hijo_reloader_activo" if is_reloader_child else ("standalone_lider" if force_leader else "proceso_unico_activo")
        _scheduler_state["modo_proceso"] = modo_proceso
        _scheduler_state["es_lider"] = True
        _scheduler_state["instancia_unica_confirmada"] = True

        logger.info(
            "[Scheduler] [PID %d] Instancia ÚNICA de APScheduler confirmada como LÍDER activo (Modo: %s, Bloqueo: %s).",
            os.getpid(),
            modo_proceso,
            lock.description(),
        )

        if ambas_presentes:
            logger.info(
                "[Scheduler] [PID %d] Ambas variables detectadas en entorno: META_SYNC_INTERVAL_SECONDS=%s y META_SYNC_INTERVAL_MINUTES=%s. Prioridad aplicada: activo en %s (%s).",
                os.getpid(),
                env_sec,
                env_min,
                intervalo_activo_str,
                origen_cfg,
            )
        else:
            logger.info(
                "[Scheduler] [PID %d] Intervalo de sincronización configurado en %s (origen: %s).",
                os.getpid(),
                intervalo_activo_str,
                origen_cfg,
            )

        _scheduler = BackgroundScheduler(daemon=True)

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

        logger.info(
            "[Scheduler] [PID %d] Trabajo programado registrado: 'job_meta_sync_periodico' (frecuencia: cada %ds / %.1f min).",
            os.getpid(),
            intervalo_segundos,
            intervalo_minutos,
        )

        if enabled:
            cls.start()
        else:
            logger.info(
                "[Scheduler] [PID %d] Planificador configurado pero DESACTIVADO (META_SYNC_ENABLED=false, intervalo: %s).",
                os.getpid(),
                intervalo_activo_str,
            )

    @classmethod
    def start(cls) -> bool:
        """Inicia el background scheduler si no está corriendo y somos líderes."""
        global _scheduler, _scheduler_state
        if _scheduler is None:
            logger.warning("[Scheduler] [PID %d] No se puede iniciar: scheduler no inicializado.", os.getpid())
            return False

        if not _scheduler.running:
            _scheduler.start()
            _scheduler_state["is_running"] = True
            _scheduler_state["enabled"] = True
            logger.info(
                "[Scheduler] [PID %d] Servicio de sincronización automática INICIADO (intervalo activo: %s). Instancia única confirmada.",
                os.getpid(),
                _scheduler_state["intervalo_activo"],
            )
            return True
        return True

    @classmethod
    def stop(cls) -> bool:
        """Detiene el scheduler y libera el bloqueo de líder."""
        global _scheduler, _scheduler_state, _lock_instance
        detenido = False
        if _scheduler is not None and _scheduler.running:
            _scheduler.shutdown(wait=False)
            _scheduler = None
            _scheduler_state["is_running"] = False
            _scheduler_state["enabled"] = False
            _scheduler_state["instancia_unica_confirmada"] = False
            logger.info("[Scheduler] [PID %d] Servicio de sincronización automática DETENIDO.", os.getpid())
            detenido = True
        elif _scheduler is not None:
            _scheduler = None

        if _lock_instance:
            _lock_instance.release()
            _scheduler_state["bloqueo_adquirido"] = False
            _scheduler_state["es_lider"] = False

        return detenido

    @classmethod
    def get_status(cls) -> dict[str, Any]:
        """Retorna el estado operativo completo y de diagnóstico del planificador."""
        global _scheduler, _scheduler_state, _coordinator

        is_running = _scheduler is not None and _scheduler.running
        job_info = None

        if is_running and _scheduler:
            job = _scheduler.get_job("job_meta_sync_periodico")
            if job:
                job_info = {
                    "id": job.id,
                    "name": job.name,
                    "intervalo_segundos": _scheduler_state["interval_seconds"],
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
            "pid": os.getpid(),
            "es_lider": _scheduler_state["es_lider"],
            "modo_proceso": _scheduler_state["modo_proceso"],
            "tipo_bloqueo": _scheduler_state["tipo_bloqueo"],
            "bloqueo_adquirido": _scheduler_state["bloqueo_adquirido"],
            "instancia_unica_confirmada": is_running and _scheduler_state["es_lider"],
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
