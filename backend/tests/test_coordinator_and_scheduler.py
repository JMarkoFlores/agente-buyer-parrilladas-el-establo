"""
Pruebas de Unidad e Integración para el Agente Coordinador y el Scheduler:
- Coordinación de AgenteFacebook y AgenteInstagram.
- Manejo independiente de fallos: si una plataforma falla, la otra continúa.
- Prevención de ejecuciones concurrentes simultáneas.
- Ciclo de vida y estado del SyncSchedulerService.
- Prevención de duplicación causada por Werkzeug Debug Reloader (proceso padre vs proceso hijo).
- Bloqueo inter-proceso de instancia única (FileProcessLock y Leader Election).
- Sincronización exacta cada 60 segundos (META_SYNC_INTERVAL_MINUTES=1).
- Modo independiente / Standalone Worker para producción.
"""
from __future__ import annotations

import os
from unittest.mock import MagicMock, patch
import pytest
from flask import Flask

from app.agents.buyer_coordinator import BuyerCoordinator, SincronizacionEnCursoError
from app.services.sync_scheduler import (
    SyncSchedulerService,
    FileProcessLock,
    NoOpLock,
    _scheduler_state,
)


@pytest.fixture(autouse=True)
def cleanup_scheduler_state():
    """Garantiza estado limpio del scheduler antes y después de cada prueba."""
    SyncSchedulerService.reset_for_testing()
    yield
    SyncSchedulerService.reset_for_testing()


def test_coordinador_ejecuta_ambas_plataformas(app):
    """Verifica que el coordinador ejecuta Facebook e Instagram e integra los totales."""
    mock_fb = MagicMock()
    mock_fb.sincronizar.return_value = {
        "success": True,
        "resumen": {
            "publicaciones": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "comentarios": {"nuevos": 2, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 1, "reutilizados": 0},
        },
    }

    mock_ig = MagicMock()
    mock_ig.sincronizar.return_value = {
        "success": True,
        "resumen": {
            "publicaciones": {"nuevos": 2, "actualizados": 1, "fallidos": 0},
            "comentarios": {"nuevos": 3, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 2, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 1, "reutilizados": 1},
        },
    }

    with app.app_context():
        coord = BuyerCoordinator(fb_agent=mock_fb, ig_agent=mock_ig)
        res = coord.sincronizar(plataforma="todas", clasificar_comentarios=False)

        assert res["success"] is True
        assert res["estado"] == "EXITOSO"
        assert "FACEBOOK" in res["plataformas_exitosas"]
        assert "INSTAGRAM" in res["plataformas_exitosas"]

        totales = res["resumen_total"]
        assert totales["publicaciones"]["nuevos"] == 3
        assert totales["comentarios"]["nuevos"] == 5
        assert totales["metricas"]["nuevos"] == 3
        assert totales["buyers"]["nuevos"] == 2


def test_coordinador_fallo_independiente_fb(app):
    """Si Facebook falla, Instagram debe continuar y el resultado ser parcial."""
    mock_fb = MagicMock()
    mock_fb.sincronizar.side_effect = Exception("Meta Graph API Timeout en Facebook")

    mock_ig = MagicMock()
    mock_ig.sincronizar.return_value = {
        "success": True,
        "resumen": {
            "publicaciones": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "comentarios": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 1, "reutilizados": 0},
        },
    }

    with app.app_context():
        coord = BuyerCoordinator(fb_agent=mock_fb, ig_agent=mock_ig)
        res = coord.sincronizar(plataforma="todas", clasificar_comentarios=False)

        # Instagram fue exitoso
        assert res["success"] is True
        assert res["estado"] == "PARCIAL"
        assert "INSTAGRAM" in res["plataformas_exitosas"]
        assert "FACEBOOK" in res["plataformas_fallidas"]
        assert len(res["errores"]) == 1
        assert "Facebook" in res["errores"][0]


def test_coordinador_fallo_independiente_ig(app):
    """Si Instagram falla, Facebook debe continuar exitosamente."""
    mock_fb = MagicMock()
    mock_fb.sincronizar.return_value = {
        "success": True,
        "resumen": {
            "publicaciones": {"nuevos": 2, "actualizados": 0, "fallidos": 0},
            "comentarios": {"nuevos": 2, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 2, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 0, "reutilizados": 0},
        },
    }

    mock_ig = MagicMock()
    mock_ig.sincronizar.side_effect = Exception("Instagram Account ID no válido")

    with app.app_context():
        coord = BuyerCoordinator(fb_agent=mock_fb, ig_agent=mock_ig)
        res = coord.sincronizar(plataforma="todas", clasificar_comentarios=False)

        assert res["success"] is True
        assert res["estado"] == "PARCIAL"
        assert "FACEBOOK" in res["plataformas_exitosas"]
        assert "INSTAGRAM" in res["plataformas_fallidas"]


def test_coordinador_bloqueo_concurrencia(app):
    """Verifica que no se permiten dos sincronizaciones simultáneas sobre la misma instancia."""
    mock_fb = MagicMock()
    mock_ig = MagicMock()

    coord = BuyerCoordinator(fb_agent=mock_fb, ig_agent=mock_ig)

    # Simular que el lock está tomado
    coord._lock.acquire()
    try:
        with pytest.raises(SincronizacionEnCursoError):
            coord.sincronizar(plataforma="todas")
    finally:
        coord._lock.release()


def test_scheduler_status(app):
    """Consulta el estado del planificador e incluye metadatos de líder y PID."""
    with app.app_context():
        status = SyncSchedulerService.get_status()
        assert "scheduler_activo" in status
        assert "intervalo_segundos" in status
        assert "intervalo_minutos" in status
        assert "intervalo_activo" in status
        assert "origen_configuracion" in status
        assert "coordinador" in status
        assert "pid" in status
        assert "es_lider" in status
        assert "modo_proceso" in status
        assert "tipo_bloqueo" in status
        assert "instancia_unica_confirmada" in status


def test_scheduler_intervalo_segundos_prioridad(app, monkeypatch):
    """Si ambas variables están presentes, prioriza segundos y reporta origen."""
    monkeypatch.setenv("META_SYNC_INTERVAL_SECONDS", "10")
    monkeypatch.setenv("META_SYNC_INTERVAL_MINUTES", "1")
    monkeypatch.setenv("SCHEDULER_LOCK_TYPE", "none")

    test_app = Flask("test_scheduler_app")
    test_app.config["META_SYNC_ENABLED"] = False
    test_app.config["META_SYNC_INTERVAL_SECONDS"] = 10
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 1.0
    test_app.config["META_SYNC_INTERVAL_ORIGEN"] = "META_SYNC_INTERVAL_SECONDS"

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["intervalo_segundos"] == 10
    assert "10 segundos" in status["intervalo_activo"]
    assert status["ambas_variables_presentes"] is True
    assert status["origen_configuracion"] == "META_SYNC_INTERVAL_SECONDS"


def test_scheduler_compatibilidad_minutos(monkeypatch):
    """Compatibilidad: si solo se define minutos, se convierte a segundos (1 min = 60s)."""
    monkeypatch.delenv("META_SYNC_INTERVAL_SECONDS", raising=False)
    monkeypatch.setenv("META_SYNC_INTERVAL_MINUTES", "1")
    monkeypatch.setenv("SCHEDULER_LOCK_TYPE", "none")

    test_app = Flask("test_scheduler_compat")
    test_app.config["META_SYNC_ENABLED"] = False
    test_app.config["META_SYNC_INTERVAL_SECONDS"] = None
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 1.0
    test_app.config["META_SYNC_INTERVAL_ORIGEN"] = "META_SYNC_INTERVAL_MINUTES"

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["intervalo_segundos"] == 60
    assert status["intervalo_minutos"] == 1.0
    assert "1.0 minutos (60s)" in status["intervalo_activo"]
    assert status["ambas_variables_presentes"] is False


def test_scheduler_rate_limit_backoff(app):
    """Ante error 429 de Meta, activa enfriamiento temporal (cooldown)."""
    import app.services.sync_scheduler as ss

    with patch.object(ss._coordinator, "sincronizar", side_effect=Exception("HTTP 429: User request limit reached")):
        resultado = ss._ejecutar_ciclo_sincronizacion(app, "todas")
        assert resultado["success"] is False
        assert ss._rate_limit_cooldown_until is not None
        assert ss._scheduler_state["rate_limit_cooldown_activo"] is True

        # El siguiente intento inmediato debe ser omitido por cooldown
        resultado_omitido = ss._ejecutar_ciclo_sincronizacion(app, "todas")
        assert resultado_omitido["success"] is False
        assert resultado_omitido.get("omitido_por_rate_limit") is True

    ss._rate_limit_cooldown_until = None
    ss._scheduler_state["rate_limit_cooldown_activo"] = False


# ==============================================================================
# PRUEBAS DEL RELOADER Y PREVENCIÓN DE DUPLICACIÓN (PROMPT ACTUAL)
# ==============================================================================

def test_scheduler_reloader_parent_skips_initialization(monkeypatch):
    """
    Verifica que el proceso monitor padre de Flask Debug Reloader (WERKZEUG_RUN_MAIN no presente)
    NO inicializa ni arranca APScheduler, evitando la primera instancia duplicada.
    """
    monkeypatch.delenv("WERKZEUG_RUN_MAIN", raising=False)
    monkeypatch.setenv("FLASK_ENV", "development")

    test_app = Flask("test_reloader_parent")
    test_app.debug = True
    test_app.config["META_SYNC_ENABLED"] = True

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["scheduler_activo"] is False, "El proceso monitor padre no debe arrancar el scheduler"
    assert status["es_lider"] is False
    assert status["modo_proceso"] == "monitor_padre_reloader"
    assert status["instancia_unica_confirmada"] is False


def test_scheduler_reloader_child_starts_single_instance(monkeypatch):
    """
    Verifica que el proceso hijo del reloader (WERKZEUG_RUN_MAIN='true') SÍ arranca APScheduler
    como líder exclusivo, con el job de 60 segundos registrado.
    """
    monkeypatch.setenv("WERKZEUG_RUN_MAIN", "true")
    monkeypatch.setenv("FLASK_ENV", "development")
    monkeypatch.setenv("SCHEDULER_LOCK_TYPE", "none")  # Aislamiento para prueba unitaria

    test_app = Flask("test_reloader_child")
    test_app.debug = True
    test_app.config["META_SYNC_ENABLED"] = True
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 1.0

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["scheduler_activo"] is True, "El proceso hijo del reloader debe activar el scheduler"
    assert status["es_lider"] is True
    assert status["modo_proceso"] == "hijo_reloader_activo"
    assert status["instancia_unica_confirmada"] is True
    assert status["intervalo_segundos"] == 60

    job_info = status["trabajo_programado"]
    assert job_info is not None
    assert job_info["id"] == "job_meta_sync_periodico"
    assert job_info["intervalo_segundos"] == 60


def test_scheduler_lock_rejects_second_concurrent_instance(monkeypatch, tmp_path):
    """
    Verifica que si otro proceso o worker ya tiene el bloqueo de líder adquirido,
    un segundo worker no arranca APScheduler y se clasifica como 'worker_secundario'.
    """
    monkeypatch.setenv("WERKZEUG_RUN_MAIN", "true")
    lock_file = str(tmp_path / "test_exclusive_scheduler.lock")
    monkeypatch.setenv("SCHEDULER_LOCK_FILE", lock_file)
    monkeypatch.setenv("SCHEDULER_LOCK_TYPE", "file")

    # 1. Simular proceso 1 que adquiere el lock de archivo
    mock_lock_holder = FileProcessLock(lock_file)
    acquired = mock_lock_holder.acquire()
    assert acquired is True, "El primer titular debe adquirir el bloqueo"

    try:
        # 2. Proceso 2 intenta inicializar el scheduler con el mismo lockfile
        test_app = Flask("test_second_worker")
        test_app.debug = False
        test_app.config["META_SYNC_ENABLED"] = True

        SyncSchedulerService.init_app(test_app)

        status = SyncSchedulerService.get_status()
        assert status["scheduler_activo"] is False, "El segundo worker NO debe arrancar APScheduler"
        assert status["es_lider"] is False
        assert status["bloqueo_adquirido"] is False
        assert status["modo_proceso"] == "worker_secundario"
        assert status["instancia_unica_confirmada"] is False
    finally:
        mock_lock_holder.release()


def test_scheduler_standalone_mode_skips_web(monkeypatch):
    """
    Verifica que cuando SCHEDULER_STANDALONE=true, el servidor web omite el inicio
    del planificador embebido para dejar que un worker dedicado lo ejecute.
    """
    monkeypatch.setenv("SCHEDULER_STANDALONE", "true")
    monkeypatch.setenv("WERKZEUG_RUN_MAIN", "true")

    test_app = Flask("test_web_standalone")
    test_app.config["META_SYNC_ENABLED"] = True

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["scheduler_activo"] is False
    assert status["modo_proceso"] == "standalone_externo"
    assert status["es_lider"] is False


def test_scheduler_intervalo_60_segundos_frecuencia_exacta(monkeypatch):
    """
    Verifica que la configuración por defecto de 60 segundos para Facebook e Instagram
    registra el trigger periódico de APScheduler con exactamente 60 segundos.
    """
    monkeypatch.setenv("META_SYNC_INTERVAL_MINUTES", "1")
    monkeypatch.delenv("META_SYNC_INTERVAL_SECONDS", raising=False)
    monkeypatch.setenv("WERKZEUG_RUN_MAIN", "true")
    monkeypatch.setenv("SCHEDULER_LOCK_TYPE", "none")

    test_app = Flask("test_60s_interval")
    test_app.config["META_SYNC_ENABLED"] = True
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 1.0

    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["intervalo_segundos"] == 60
    assert status["intervalo_minutos"] == 1.0

    # Verificar trabajo en APScheduler
    job = status["trabajo_programado"]
    assert job is not None
    assert job["id"] == "job_meta_sync_periodico"
    assert "cada 60s" in job["name"]
