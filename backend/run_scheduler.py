"""
Ejecutor Independiente del Planificador de Sincronización (Standalone Worker).
Diseñado para entornos de producción (Docker, Kubernetes, contenedores o servicios systemd/Windows):
- Se ejecuta en un proceso dedicado separado de los servidores web WSGI (Gunicorn / Waitress).
- Ejecuta los ciclos de sincronización de Meta (Facebook e Instagram) cada 60 segundos.
- Adquiere bloqueo de proceso exclusivo (FileLock o SQL Server AppLock).
- Maneja señales SIGINT y SIGTERM para apagado controlado y liberación de recursos.

Uso:
    python run_scheduler.py
"""
from __future__ import annotations

import logging
import os
import signal
import sys
import time
from pathlib import Path

# Asegurar que el directorio backend está en sys.path
backend_dir = Path(__file__).resolve().parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from app import create_app
from app.services.sync_scheduler import SyncSchedulerService

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] %(name)s (PID %(process)d): %(message)s",
)
logger = logging.getLogger("scheduler_runner")


def main() -> None:
    # Indicar que este proceso es el ejecutor standalone dedicado
    os.environ["SCHEDULER_STANDALONE"] = "false"  # Permitir inicialización aquí
    os.environ["META_SYNC_ENABLED"] = "true"

    logger.info("=" * 70)
    logger.info("  AGENTE BUYER — PLANIFICADOR DE SINCRONIZACIÓN STANDALONE (PRODUCCIÓN)")
    logger.info("  PID: %d | Frecuencia: Facebook e Instagram cada 60s", os.getpid())
    logger.info("=" * 70)

    app = create_app()

    with app.app_context():
        SyncSchedulerService.init_app(app, force_leader=True)

    status = SyncSchedulerService.get_status()
    logger.info(
        "[Standalone] Planificador iniciado: Activo=%s, Intervalo=%s, Modo=%s, Bloqueo=%s",
        status.get("scheduler_activo"),
        status.get("intervalo_activo"),
        status.get("modo_proceso"),
        status.get("tipo_bloqueo"),
    )

    stop_requested = False

    def handle_signal(sig, frame):
        nonlocal stop_requested
        logger.info("[Standalone] Señal de terminación recibida (%s). Deteniendo scheduler...", sig)
        stop_requested = True
        SyncSchedulerService.stop()
        logger.info("[Standalone] Scheduler detenido correctamente. Saliendo.")
        sys.exit(0)

    signal.signal(signal.SIGINT, handle_signal)
    signal.signal(signal.SIGTERM, handle_signal)

    logger.info("[Standalone] Worker ejecutándose en primer plano. Presione Ctrl+C para finalizar.")
    while not stop_requested:
        time.sleep(1)


if __name__ == "__main__":
    main()
