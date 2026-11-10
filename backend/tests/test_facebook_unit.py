"""
Pruebas Unitarias para el Agente de Captación de Facebook.
Utilizan simulación (mocks) de Meta Graph API para validar exhaustivamente:
- Manejo de tokens y enmascaramiento seguro en logs y errores.
- Respuestas HTTP 400, 401, 403, 429 y reintentos.
- Paginación mediante cursores de Meta.
- Autenticación de administración para /api/facebook/sincronizar.
- Creación de BUYER solo cuando el usuario es identificable y distinto de la página.
- NO creación de registros en dbo.persona.
- Respeto de valores NULL para métricas no disponibles (no sustituir por 0).
- Idempotencia y deduplicación.
"""
from datetime import datetime, date, timezone
from unittest.mock import MagicMock, patch
import pytest
import requests

from app.integrations.meta_client import (
    MetaGraphClient,
    MetaClientError,
    MetaAuthError,
    MetaPermissionError,
    MetaRateLimitError,
    mask_token,
    sanitize_text,
)
from app.services.facebook_service import extract_form_url, parse_meta_datetime


@pytest.fixture(autouse=True)
def cleanup_test_data(app):
    """Limpia registros de prueba tras la ejecución para mantener la base de datos limpia."""
    yield
    with app.app_context():
        from app.extensions import db
        from app.models.marketing import Publicacion, MetricaPublicacionDiaria
        from app.models.persona import Buyer, InteraccionPublicacion
        from app.models.auditoria import EventoIntegracion

        db.session.query(InteraccionPublicacion).filter(
            InteraccionPublicacion.id_interaccion_externa.like("FB_%")
        ).delete(synchronize_session=False)

        db.session.query(Buyer).filter(
            Buyer.referencia_externa.like("USER_%")
        ).delete(synchronize_session=False)

        test_posts = db.session.query(Publicacion).filter(
            Publicacion.meta_post_id.like("FB_%")
        ).all()
        test_post_ids = [p.id_publicacion for p in test_posts]
        if test_post_ids:
            db.session.query(MetricaPublicacionDiaria).filter(
                MetricaPublicacionDiaria.id_publicacion.in_(test_post_ids)
            ).delete(synchronize_session=False)
            db.session.query(Publicacion).filter(
                Publicacion.id_publicacion.in_(test_post_ids)
            ).delete(synchronize_session=False)

        db.session.query(EventoIntegracion).filter(
            EventoIntegracion.id_evento_externo.like("FB_%")
        ).delete(synchronize_session=False)

        db.session.commit()



# =============================================================================
# 1. Pruebas del Cliente Meta: Seguridad, Errores y Paginación
# =============================================================================

def test_token_masking_and_sanitization():
    """El token NUNCA debe ser expuesto en texto claro en logs ni cadenas de error."""
    raw_token = "EAABwzLixnjYBO8918237918273981273918273"
    masked = mask_token(raw_token)
    assert raw_token not in masked
    assert masked.startswith("EAAB...")
    assert masked.endswith("8273")

    # Sanitización de URLs con access_token
    url = f"https://graph.facebook.com/v21.0/12345/posts?access_token={raw_token}&limit=25"
    sanitized = sanitize_text(url, raw_token)
    assert raw_token not in sanitized
    assert "[REDACTED" in sanitized

    # Sanitización de encabezados Authorization
    auth_header = f"Bearer {raw_token}"
    sanitized_auth = sanitize_text(auth_header, raw_token)
    assert raw_token not in sanitized_auth
    assert "Bearer [REDACTED" in sanitized_auth


def test_meta_client_handles_401_invalid_token():
    """HTTP 401 o código OAuth 190 genera MetaAuthError sanitizado."""
    fake_token = "INVALID_TOKEN_12345"
    mock_session = MagicMock()
    mock_response = MagicMock()
    mock_response.status_code = 401
    mock_response.json.return_value = {
        "error": {
            "message": f"Invalid OAuth access token: {fake_token}",
            "type": "OAuthException",
            "code": 190,
            "error_subcode": 463,
        }
    }
    mock_session.request.return_value = mock_response

    client = MetaGraphClient(access_token=fake_token, session=mock_session, max_retries=1)

    with pytest.raises(MetaAuthError) as exc_info:
        client.get_page_info("123456789")

    # Verificar que el token fue sanitizado del mensaje de error
    assert fake_token not in str(exc_info.value)
    assert exc_info.value.status_code == 401


def test_meta_client_handles_403_insufficient_permissions():
    """HTTP 403 o error de permisos genera MetaPermissionError."""
    mock_session = MagicMock()
    mock_response = MagicMock()
    mock_response.status_code = 403
    mock_response.json.return_value = {
        "error": {
            "message": "(#200) Provide valid app ID or read_insights permission",
            "type": "OAuthException",
            "code": 200,
        }
    }
    mock_session.request.return_value = mock_response

    client = MetaGraphClient(access_token="valid_token", session=mock_session, max_retries=1)

    with pytest.raises(MetaPermissionError) as exc_info:
        client.get_published_posts("123456789")

    assert "Permisos insuficientes" in str(exc_info.value)
    assert exc_info.value.status_code == 403


def test_meta_client_handles_429_rate_limit_and_retries():
    """HTTP 429 activa reintentos controlados con backoff."""
    mock_session = MagicMock()

    # Primer intento: 429
    res_429 = MagicMock()
    res_429.status_code = 429
    res_429.json.return_value = {
        "error": {
            "message": "User request limit reached",
            "type": "OAuthException",
            "code": 17,
        }
    }

    # Segundo intento: 200 OK
    res_200 = MagicMock()
    res_200.status_code = 200
    res_200.json.return_value = {"id": "123456", "name": "Parrilladas El Establo"}

    mock_session.request.side_effect = [res_429, res_200]

    with patch("time.sleep", return_value=None):
        client = MetaGraphClient(access_token="test_tok", session=mock_session, max_retries=2)
        info = client.get_page_info("123456")

    assert info["id"] == "123456"
    assert mock_session.request.call_count == 2


def test_meta_client_pagination_with_cursors():
    """La paginación con cursores sigue el enlace paging.next."""
    mock_session = MagicMock()

    # Página 1
    page1 = MagicMock()
    page1.status_code = 200
    page1.json.return_value = {
        "data": [{"id": "post_1", "message": "Primer post"}],
        "paging": {
            "cursors": {"after": "cursor_page_1"},
            "next": "https://graph.facebook.com/v21.0/page_id/published_posts?after=cursor_page_1",
        },
    }

    # Página 2 (última)
    page2 = MagicMock()
    page2.status_code = 200
    page2.json.return_value = {
        "data": [{"id": "post_2", "message": "Segundo post"}],
        "paging": {"cursors": {"after": "cursor_page_2"}},
    }

    mock_session.request.side_effect = [page1, page2]

    client = MetaGraphClient(access_token="tok", session=mock_session, page_id="page_id")
    posts = client.get_published_posts(limit=1, max_pages=3)

    assert len(posts) == 2
    assert posts[0]["id"] == "post_1"
    assert posts[1]["id"] == "post_2"


def test_extract_form_url_helper():
    """Detección inteligente de enlaces de formularios en el texto de la publicación."""
    text_with_form = "¡Gran promoción de cortes! Llena nuestro formulario: https://establo.pe/formulario?src=fb hoy."
    assert extract_form_url(text_with_form) == "https://establo.pe/formulario?src=fb"

    text_with_menu = "Visita nuestra carta en https://establo.pe/menu para ver los precios."
    assert extract_form_url(text_with_menu) == "https://establo.pe/menu"

    text_without_url = "Los mejores cortes de carne están en Parrilladas El Establo."
    assert extract_form_url(text_without_url) is None


# =============================================================================
# 2. Pruebas de Endpoints de Facebook
# =============================================================================

def test_facebook_status_not_configured(client, app, monkeypatch):
    """GET /api/facebook/status devuelve diagnóstico cuando el token no está configurado."""
    monkeypatch.setitem(app.config, "META_PAGE_ACCESS_TOKEN", "")

    response = client.get("/api/facebook/status")
    assert response.status_code == 200
    data = response.get_json()

    assert data["success"] is True
    status_info = data["data"]
    assert status_info["conectado"] is False
    assert status_info["estado"] == "no_configurado"
    assert "token_configurado" in status_info
    assert status_info["token_configurado"] is False
    assert "pages_read_engagement" in status_info["permisos_pendientes"]


def test_facebook_sincronizar_requires_admin_auth(client):
    """POST /api/facebook/sincronizar rechaza peticiones sin autenticación de administración (401)."""
    # 1. Sin header
    res_no_auth = client.post("/api/facebook/sincronizar")
    assert res_no_auth.status_code == 401
    assert res_no_auth.get_json()["success"] is False

    # 2. Con token incorrecto
    res_bad_auth = client.post(
        "/api/facebook/sincronizar",
        headers={"X-Admin-Token": "clave_incorrecta"},
    )
    assert res_bad_auth.status_code == 401
    assert res_bad_auth.get_json()["success"] is False


def test_facebook_sincronizar_with_valid_admin_token_mocked(client, app, monkeypatch):
    """
    POST /api/facebook/sincronizar con admin auth válido procesa publicaciones,
    comentarios, BUYERS y métricas.
    """
    import time
    from app.services.facebook_service import FacebookService

    admin_key = app.config.get("ADMIN_API_KEY", "admin-establo-buyer-secret-2026")
    test_uid = f"{time.time_ns()}"

    # Mocks de datos de Meta
    mock_posts = [
        {
            "id": f"FB_MOCK_POST_{test_uid}",
            "message": "Promoción especial de Picaña. Formulario: https://establo.pe/formulario",
            "permalink_url": f"https://facebook.com/establo/posts/{test_uid}",
            "created_time": "2026-11-09T10:00:00+0000",
            "reactions": {"summary": {"total_count": 55}},
            "comments": {"summary": {"total_count": 2}},
            "shares": {"count": 12},
        }
    ]

    mock_comments = [
        {
            "id": f"FB_MOCK_COMMENT_{test_uid}_1",
            "message": "¡Quiero información de la promoción!",
            "created_time": "2026-11-09T10:30:00+0000",
            "from": {"id": f"USER_MOCK_{test_uid}", "name": "Carlos Mendoza"},
            "parent": None,
        },
        {
            "id": f"FB_MOCK_COMMENT_{test_uid}_2",
            "message": "¡Hola Carlos! Te enviamos detalles por inbox.",
            "created_time": "2026-11-09T10:35:00+0000",
            "from": {"id": "PAGE_ID_ESTABLO", "name": "Parrilladas El Establo"},  # La propia página
            "parent": {"id": f"FB_MOCK_COMMENT_{test_uid}_1"},
        },
    ]

    mock_client = MagicMock()
    mock_client.access_token = "mock_token"
    mock_client.page_id = "PAGE_ID_ESTABLO"
    mock_client.get_published_posts.return_value = mock_posts
    mock_client.get_post_comments.return_value = mock_comments
    mock_client.get_post_insights.return_value = {"alcance": 450, "impresiones": 820}

    # Inyectar cliente mock en el servicio
    mock_service = FacebookService(client=mock_client)
    monkeypatch.setattr("app.routes.facebook_routes.service", mock_service)

    response = client.post(
        "/api/facebook/sincronizar",
        headers={"X-Admin-Token": admin_key},
    )

    assert response.status_code == 200
    body = response.get_json()
    assert body["success"] is True

    resumen = body["resumen"]
    assert "publicaciones" in resumen
    assert "comentarios" in resumen
    assert "metricas" in resumen
    assert "buyers" in resumen

    # Se procesó la publicación
    assert resumen["publicaciones"]["nuevos"] == 1
    # Se procesaron 2 comentarios nuevos
    assert resumen["comentarios"]["nuevos"] == 2
    # Regla BUYER: Carlos genera 1 BUYER nuevo, NO la propia página
    assert resumen["buyers"]["nuevos"] == 1



def test_get_facebook_publicaciones_endpoint(client):
    """GET /api/facebook/publicaciones devuelve lista estructurada con paginación."""
    response = client.get("/api/facebook/publicaciones")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert "total" in data
    assert isinstance(data["data"], list)


def test_get_facebook_metricas_endpoint(client):
    """GET /api/facebook/metricas devuelve lista de métricas diarias."""
    response = client.get("/api/facebook/metricas")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True
    assert "total" in data
    assert isinstance(data["data"], list)


def test_get_facebook_comentarios_404_on_invalid_id(client):
    """GET /api/facebook/publicaciones/<id>/comentarios devuelve 404 para ID inexistente."""
    response = client.get("/api/facebook/publicaciones/999999/comentarios")
    assert response.status_code == 404
    data = response.get_json()
    assert data["success"] is False
    assert "Publicación no encontrada" in data["error"]


def test_idempotent_sync_no_duplicates_and_no_fake_personas(client, app, monkeypatch):
    """
    7. Ejecutar sincronización nuevamente y comprobar que no se duplicaron registros.
    10. Verificar que NUNCA se hayan creado registros en dbo.persona.
    """
    from app.extensions import db
    from app.models.persona import Persona, Buyer, InteraccionPublicacion
    from app.models.marketing import Publicacion, MetricaPublicacionDiaria
    from app.services.facebook_service import FacebookService

    import time
    admin_key = app.config.get("ADMIN_API_KEY", "admin-establo-buyer-secret-2026")
    uid = f"{time.time_ns()}"

    post_id = f"FB_IDEMPOTENT_POST_{uid}"
    comment_id = f"FB_IDEMPOTENT_COMMENT_{uid}"
    user_id = f"USER_IDEMPOTENT_{uid}"

    mock_posts = [
        {
            "id": post_id,
            "message": "Corte New York Steak a la brasa. Formulario: https://establo.pe/formulario",
            "permalink_url": f"https://facebook.com/establo/posts/{uid}",
            "created_time": "2026-11-09T14:00:00+0000",
            "reactions": {"summary": {"total_count": 80}},
            "comments": {"summary": {"total_count": 1}},
            "shares": {"count": 5},
        }
    ]

    mock_comments = [
        {
            "id": comment_id,
            "message": "¿Qué precio tiene la promoción de New York?",
            "created_time": "2026-11-09T14:15:00+0000",
            "from": {"id": user_id, "name": "Valeria Castro"},
            "parent": None,
        }
    ]

    mock_client = MagicMock()
    mock_client.access_token = "mock_token"
    mock_client.page_id = "PAGE_ID_ESTABLO"
    mock_client.get_published_posts.return_value = mock_posts
    mock_client.get_post_comments.return_value = mock_comments
    mock_client.get_post_insights.return_value = None  # Sin permisos de insights: deben quedar NULL

    mock_service = FacebookService(client=mock_client)
    monkeypatch.setattr("app.routes.facebook_routes.service", mock_service)

    with app.app_context():
        personas_antes = db.session.query(Persona).count()
        buyers_antes = db.session.query(Buyer).count()
        publicaciones_antes = db.session.query(Publicacion).count()
        comentarios_antes = db.session.query(InteraccionPublicacion).count()

    # 1. Primera ejecución de sincronización
    res1 = client.post("/api/facebook/sincronizar", headers={"X-Admin-Token": admin_key})
    assert res1.status_code == 200
    body1 = res1.get_json()
    assert body1["resumen"]["publicaciones"]["nuevos"] == 1
    assert body1["resumen"]["comentarios"]["nuevos"] == 1
    assert body1["resumen"]["buyers"]["nuevos"] == 1

    with app.app_context():
        personas_despues_1 = db.session.query(Persona).count()
        # REGLA 10: Nunca se deben crear personas ficticias
        assert personas_despues_1 == personas_antes, "¡Alerta! Se creó un registro indebido en dbo.persona"

        # Verificar que el nuevo buyer tiene id_persona = NULL
        nuevo_buyer = db.session.query(Buyer).filter(Buyer.referencia_externa == user_id).first()
        assert nuevo_buyer is not None
        assert nuevo_buyer.id_persona is None
        assert nuevo_buyer.estado == "BUYER"

        # Verificar que las métricas sin insights quedaron con alcance e impresiones NULL (no 0)
        pub_db = db.session.query(Publicacion).filter(Publicacion.meta_post_id == post_id).first()
        metrica_db = db.session.query(MetricaPublicacionDiaria).filter(MetricaPublicacionDiaria.id_publicacion == pub_db.id_publicacion).first()
        assert metrica_db is not None
        assert metrica_db.total_reacciones == 80
        assert metrica_db.alcance is None
        assert metrica_db.impresiones is None


    # 2. Segunda ejecución de sincronización con la misma información (Prueba de Idempotencia)
    res2 = client.post("/api/facebook/sincronizar", headers={"X-Admin-Token": admin_key})
    assert res2.status_code == 200
    body2 = res2.get_json()

    # REGLA 7: Comprobar que NO se duplicaron registros
    assert body2["resumen"]["publicaciones"]["nuevos"] == 0
    assert body2["resumen"]["publicaciones"]["actualizados"] == 1
    assert body2["resumen"]["comentarios"]["nuevos"] == 0
    assert body2["resumen"]["comentarios"]["actualizados"] == 1
    assert body2["resumen"]["buyers"]["nuevos"] == 0
    assert body2["resumen"]["buyers"]["reutilizados"] == 1

    with app.app_context():
        personas_final = db.session.query(Persona).count()
        buyers_final = db.session.query(Buyer).count()
        publicaciones_final = db.session.query(Publicacion).count()
        comentarios_final = db.session.query(InteraccionPublicacion).count()

        assert personas_final == personas_antes
        assert buyers_final == buyers_antes + 1
        assert publicaciones_final == publicaciones_antes + 1
        assert comentarios_final == comentarios_antes + 1


def test_invalid_token_reported_truthfully(client, app, monkeypatch):
    """
    8. Probar error de token inválido.
    NO utilizar datos simulados para afirmar que Facebook está conectado.
    """
    monkeypatch.setitem(app.config, "META_PAGE_ACCESS_TOKEN", "TOKEN_TOTALMENTE_INVALIDO_XYZ")
    monkeypatch.setitem(app.config, "META_PAGE_ID", "123456789")

    # Mock de respuesta 401 de Meta
    mock_client = MagicMock()
    mock_client.access_token = "TOKEN_TOTALMENTE_INVALIDO_XYZ"
    mock_client.page_id = "123456789"
    mock_client.verify_connection.return_value = {
        "conectado": False,
        "motivo": "Token inválido o expirado: Error de autenticación con Meta Graph API (HTTP 401).",
        "page_id": "123456789",
    }

    from app.services.facebook_service import FacebookService
    mock_service = FacebookService(client=mock_client)
    monkeypatch.setattr("app.routes.facebook_routes.service", mock_service)

    response = client.get("/api/facebook/status")
    assert response.status_code == 200
    data = response.get_json()

    assert data["success"] is True
    status = data["data"]
    assert status["conectado"] is False
    assert status["estado"] == "error_autenticacion"
    assert "Token inválido o expirado" in status["mensaje"]
    assert status["capacidades"]["lectura_publicaciones"] is False

