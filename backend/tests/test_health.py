"""
Pruebas para comprobar que Flask inicia correctamente y responde en /api/health.
"""


def test_flask_starts_and_health_returns_200(client):
    """1. Flask inicia correctamente y /api/health responde con estado 200 y JSON válido."""
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    data = response.get_json()
    assert data is not None
    assert data.get("status") == "healthy"
    assert "El Establo" in data.get("service", "")
    assert data.get("version") == "1.0.0"
    assert "timestamp_utc" in data
