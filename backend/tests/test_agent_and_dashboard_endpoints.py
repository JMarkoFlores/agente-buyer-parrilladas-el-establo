"""
Pruebas de Integración para los Endpoints REST de Agentes y Dashboard:
- GET  /api/agentes/status
- POST /api/agentes/sincronizar (Protección administrativa con ADMIN_API_KEY)
- GET  /api/agentes/actividad
- GET  /api/dashboard/resumen
- GET  /api/dashboard/comentarios
- GET  /api/dashboard/buyers
- GET  /dashboard (Interfaz HTML)
"""
from unittest.mock import patch


def test_get_agentes_status(client):
    """GET /api/agentes/status retorna estructura completa de agentes."""
    res = client.get("/api/agentes/status")
    assert res.status_code == 200
    assert res.content_type == "application/json"

    body = res.get_json()
    assert body["success"] is True
    data = body["data"]

    assert "scheduler" in data
    assert "coordinador" in data
    assert "agente_facebook" in data
    assert "agente_instagram" in data


def test_post_agentes_sincronizar_sin_auth(client):
    """POST /api/agentes/sincronizar sin clave administrativa retorna 401."""
    res = client.post("/api/agentes/sincronizar")
    assert res.status_code == 401
    body = res.get_json()
    assert body["success"] is False
    assert "No autorizado" in body["error"]


def test_post_agentes_sincronizar_token_invalido(client):
    """POST /api/agentes/sincronizar con clave inválida retorna 401."""
    res = client.post(
        "/api/agentes/sincronizar",
        headers={"X-Admin-Token": "clave-falsa-invalida-1234"},
    )
    assert res.status_code == 401
    body = res.get_json()
    assert body["success"] is False


def test_post_agentes_sincronizar_con_auth_valida(client, monkeypatch):
    """POST /api/agentes/sincronizar con ADMIN_API_KEY válida ejecuta la sincronización."""
    # Mockear la llamada de red a Meta para una ejecución limpia en prueba unitaria
    mock_res = {
        "success": True,
        "estado": "EXITOSO",
        "coordinador": "AgenteCoordinador",
        "plataformas_exitosas": ["FACEBOOK", "INSTAGRAM"],
        "plataformas_fallidas": [],
        "resumen_total": {
            "publicaciones": {"nuevos": 0, "actualizados": 1, "fallidos": 0},
            "comentarios": {"nuevos": 0, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 1, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 0, "reutilizados": 0},
        },
    }

    with patch("app.agents.buyer_coordinator.BuyerCoordinator.sincronizar", return_value=mock_res):
        res = client.post(
            "/api/agentes/sincronizar",
            headers={"X-Admin-Token": "admin-establo-buyer-secret-2026"},
            json={"plataforma": "todas"},
        )
        assert res.status_code == 200
        body = res.get_json()
        assert body["success"] is True
        assert body["estado"] == "EXITOSO"


def test_get_agentes_actividad(client):
    """GET /api/agentes/actividad retorna el historial de dbo.accion_agente."""
    res = client.get("/api/agentes/actividad?limit=10")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert "total" in body
    assert "items" in body
    assert isinstance(body["items"], list)


def test_get_dashboard_resumen(client):
    """GET /api/dashboard/resumen retorna métricas separando datos reales de demo."""
    res = client.get("/api/dashboard/resumen")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    data = body["data"]

    # Separación real vs demo
    assert "publicaciones" in data
    assert "reales" in data["publicaciones"]["facebook"]
    assert "demo" in data["publicaciones"]["facebook"]
    assert "reales" in data["publicaciones"]["instagram"]
    assert "demo" in data["publicaciones"]["instagram"]

    assert "comentarios" in data
    assert "reales" in data["comentarios"]
    assert "demo" in data["comentarios"]

    assert "buyers" in data
    assert "reales" in data["buyers"]
    assert "demo" in data["buyers"]

    assert "reacciones_likes" in data
    assert "estado_agentes" in data


def test_get_dashboard_comentarios(client):
    """GET /api/dashboard/comentarios retorna comentarios clasificados."""
    res = client.get("/api/dashboard/comentarios?limit=20")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert "items" in body
    assert isinstance(body["items"], list)

    if len(body["items"]) > 0:
        com = body["items"][0]
        assert "clasificacion_intencion" in com
        assert "plataforma" in com
        assert "origen" in com


def test_get_dashboard_buyers(client):
    """GET /api/dashboard/buyers retorna lista de prospectos con privacidad cuidada."""
    res = client.get("/api/dashboard/buyers?limit=20")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert "items" in body
    assert isinstance(body["items"], list)

    for b in body["items"]:
        assert "id_buyer" in b
        assert "plataforma_codigo" in b
        assert "estado" in b
        assert "total_interacciones" in b
        # La referencia externa debe estar enmascarada si es extensa
        ref = b.get("referencia_externa_enmascarada")
        if ref and len(ref) > 8 and not ref.startswith("DEMO_"):
            assert "***" in ref


def test_get_dashboard_html_view(client):
    """GET /dashboard retorna la página web HTML."""
    res = client.get("/dashboard")
    assert res.status_code == 200
    assert "text/html" in res.content_type
    html = res.get_data(as_text=True)
    assert "Parrilladas El Establo" in html
    assert "Agente BUYER" in html
    assert "Resumen General" in html
    assert "ADMIN_API_KEY" in html  # Texto explicativo en modal, pero nunca el valor secreto
    assert "admin-establo-buyer-secret-2026" not in html  # El token JAMÁS se expone en HTML
