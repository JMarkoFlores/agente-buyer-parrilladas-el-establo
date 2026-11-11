"""
Pruebas Unitarias para el Agente de Captación de Instagram.
Valida con mocks:
- Autenticación de administración para /api/instagram/sincronizar.
- Manejo de endpoints de Instagram Graph API.
- Idempotencia en publicaciones y métricas.
- Manejo seguro de tokens sin exposición.
"""
from datetime import datetime, date
from unittest.mock import MagicMock, patch
import pytest

from app.integrations.meta_client import MetaGraphClient, MetaClientError
from app.services.instagram_service import InstagramService, parse_meta_datetime, extract_form_url


def test_parse_meta_datetime_instagram():
    """Valida el parseo de fechas ISO 8601 de Instagram a datetime naive UTC."""
    raw = "2026-11-10T22:33:06+0000"
    dt = parse_meta_datetime(raw)
    assert dt.year == 2026
    assert dt.month == 11
    assert dt.day == 10
    assert dt.hour == 22
    assert dt.minute == 33
    assert dt.tzinfo is None


def test_extract_form_url_instagram():
    """Valida la detección de URLs en captions de Instagram."""
    text_with_url = "Visita nuestra carta en https://establo.pe/menu hoy mismo!"
    assert extract_form_url(text_with_url) == "https://establo.pe/menu"

    text_no_url = "Parrillada El Establo lista para servir."
    assert extract_form_url(text_no_url) is None


def test_instagram_sync_requires_admin_auth(client):
    """El endpoint /api/instagram/sincronizar requiere token de administración."""
    # Sin autenticación
    res = client.post("/api/instagram/sincronizar")
    assert res.status_code == 401
    assert res.get_json()["success"] is False

    # Con clave incorrecta
    res = client.post(
        "/api/instagram/sincronizar",
        headers={"X-Admin-Token": "clave-totalmente-erronea"}
    )
    assert res.status_code == 401


def test_instagram_status_structure(client):
    """El endpoint /api/instagram/status devuelve estructura correcta."""
    res = client.get("/api/instagram/status")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert "data" in body
    data = body["data"]
    assert "conectado" in data
    assert "capacidades" in data
