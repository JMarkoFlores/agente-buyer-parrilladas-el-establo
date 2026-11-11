"""
Pruebas de Unidad e Integración para el Agente Coordinador y el Scheduler:
- Coordinación de AgenteFacebook y AgenteInstagram.
- Manejo independiente de fallos: si una plataforma falla, la otra continúa.
- Prevención de ejecuciones concurrentes simultáneas.
- Ciclo de vida y estado del SyncSchedulerService.
"""
from unittest.mock import MagicMock
import pytest
from app.agents.buyer_coordinator import BuyerCoordinator, SincronizacionEnCursoError
from app.services.sync_scheduler import SyncSchedulerService


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
    """Consulta el estado del planificador."""
    with app.app_context():
        status = SyncSchedulerService.get_status()
        assert "scheduler_activo" in status
        assert "intervalo_segundos" in status
        assert "intervalo_minutos" in status
        assert "intervalo_activo" in status
        assert "origen_configuracion" in status
        assert "coordinador" in status


def test_scheduler_intervalo_segundos_prioridad(app, monkeypatch):
    """Si ambas variables están presentes, prioriza segundos y reporta origen."""
    monkeypatch.setenv("META_SYNC_INTERVAL_SECONDS", "10")
    monkeypatch.setenv("META_SYNC_INTERVAL_MINUTES", "1")

    from flask import Flask
    test_app = Flask("test_scheduler_app")
    test_app.config["META_SYNC_ENABLED"] = False
    test_app.config["META_SYNC_INTERVAL_SECONDS"] = 10
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 1.0
    test_app.config["META_SYNC_INTERVAL_ORIGEN"] = "META_SYNC_INTERVAL_SECONDS"

    from app.services.sync_scheduler import SyncSchedulerService, _scheduler_state
    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["intervalo_segundos"] == 10
    assert "10 segundos" in status["intervalo_activo"]
    assert status["ambas_variables_presentes"] is True
    assert status["origen_configuracion"] == "META_SYNC_INTERVAL_SECONDS"


def test_scheduler_compatibilidad_minutos(monkeypatch):
    """Compatibilidad heredada: si solo se define minutos, se convierte a segundos."""
    monkeypatch.delenv("META_SYNC_INTERVAL_SECONDS", raising=False)
    monkeypatch.setenv("META_SYNC_INTERVAL_MINUTES", "2")

    from flask import Flask
    test_app = Flask("test_scheduler_compat")
    test_app.config["META_SYNC_ENABLED"] = False
    test_app.config["META_SYNC_INTERVAL_SECONDS"] = None
    test_app.config["META_SYNC_INTERVAL_MINUTES"] = 2.0
    test_app.config["META_SYNC_INTERVAL_ORIGEN"] = "META_SYNC_INTERVAL_MINUTES"

    from app.services.sync_scheduler import SyncSchedulerService
    SyncSchedulerService.init_app(test_app)

    status = SyncSchedulerService.get_status()
    assert status["intervalo_segundos"] == 120
    assert status["intervalo_minutos"] == 2.0
    assert status["ambas_variables_presentes"] is False


def test_scheduler_rate_limit_backoff(app):
    """Ante error 429 de Meta, activa enfriamiento temporal (cooldown)."""
    import datetime
    from unittest.mock import patch
    import app.services.sync_scheduler as ss

    # Simular que el coordinador lanza error de Rate Limit 429
    with patch.object(ss._coordinator, "sincronizar", side_effect=Exception("HTTP 429: User request limit reached")):
        resultado = ss._ejecutar_ciclo_sincronizacion(app, "todas")
        assert resultado["success"] is False
        assert ss._rate_limit_cooldown_until is not None
        assert ss._scheduler_state["rate_limit_cooldown_activo"] is True

        # El siguiente intento inmediato debe ser omitido por cooldown
        resultado_omitido = ss._ejecutar_ciclo_sincronizacion(app, "todas")
        assert resultado_omitido["success"] is False
        assert resultado_omitido.get("omitido_por_rate_limit") is True

    # Limpiar estado
    ss._rate_limit_cooldown_until = None
    ss._scheduler_state["rate_limit_cooldown_activo"] = False

