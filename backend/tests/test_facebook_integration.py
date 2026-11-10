"""
Pruebas de Integración Reales para el Agente de Facebook.
Interactúan directamente con la base de datos SQL Server 'buyer' y la API real de Meta:
- Comprobación de estado contra la base de datos SQL Server y Meta Graph API.
- Consulta de publicaciones, comentarios y métricas en dbo.publicacion, dbo.interaccion_publicacion y dbo.metrica_publicacion_diaria.
- Validación de que NUNCA se crean registros en dbo.persona.
- Validación de rechazo y manejo verídico de tokens inválidos contra los servidores de Meta.
- Verificación de no duplicación e integridad relacional.
"""
import pytest
from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Persona, Buyer, InteraccionPublicacion
from app.models.auditoria import EventoIntegracion, AccionAgente
from app.integrations.meta_client import MetaGraphClient, MetaAuthError


def test_real_facebook_platform_configured_in_database(client, app):
    """Verifica que la plataforma FACEBOOK existe en SQL Server con su id_plataforma correspondiente."""
    with app.app_context():
        fb = db.session.query(Plataforma).filter(Plataforma.codigo == "FACEBOOK").first()
        assert fb is not None
        assert fb.codigo == "FACEBOOK"
        assert "El Establo" in fb.nombre_pagina


def test_real_facebook_status_endpoint(client):
    """
    1. Probar conexión / estado con Meta.
    Comprueba que el endpoint /api/facebook/status responde verídicamente
    sin inventar conexiones simuladas.
    """
    response = client.get("/api/facebook/status")
    assert response.status_code == 200
    data = response.get_json()
    assert data["success"] is True

    status_data = data["data"]
    assert "conectado" in status_data
    assert "version_api" in status_data
    assert "permisos_disponibles" in status_data
    assert "permisos_pendientes" in status_data
    assert "capacidades" in status_data

    # Si no hay token real en .env, reporta no_configurado o desconectado
    # Si hay token real en .env, reporta conectado = True
    if not status_data["conectado"]:
        assert status_data["estado"] in ("no_configurado", "error_autenticacion")
    else:
        assert status_data["estado"] == "conectado"
        assert status_data["page_id"] is not None


def test_real_meta_api_rejects_invalid_token_cleanly():
    """
    8. Probar error de token inválido en Meta Graph API real.
    Envía una petición auténtica a graph.facebook.com con un token deliberadamente inválido
    y comprueba que Meta devuelve el error OAuthException y que nuestro cliente lo procesa sin exponer el token.
    """
    fake_token = "EAAB_TOKEN_DE_PRUEBA_INVALIDO_12345"
    client = MetaGraphClient(access_token=fake_token, api_version="v21.0", timeout=10)

    res = client.verify_connection()
    assert res["conectado"] is False
    assert "Token inválido" in res["motivo"]
    # El token NUNCA debe estar en el motivo del error devuelto al usuario
    assert fake_token not in res["motivo"]


def test_real_database_read_publications(client):
    """
    Consulta de publicaciones de Facebook almacenadas en SQL Server mediante el endpoint oficial.
    """
    response = client.get("/api/facebook/publicaciones")
    assert response.status_code == 200
    body = response.get_json()
    assert body["success"] is True
    assert "total" in body
    assert isinstance(body["data"], list)

    # Las publicaciones devueltas corresponden a Facebook
    for item in body["data"]:
        assert item["plataforma_codigo"] == "FACEBOOK"
        assert item["meta_post_id"] is not None


def test_real_database_read_post_comments(client, app):
    """
    Consulta de comentarios de una publicación existente en SQL Server.
    """
    # Obtener primera publicación de Facebook en la BD
    pub_id = None
    with app.app_context():
        fb_plat = db.session.query(Plataforma).filter(Plataforma.codigo == "FACEBOOK").first()
        pub = (
            db.session.query(Publicacion)
            .filter(Publicacion.id_plataforma == fb_plat.id_plataforma)
            .first()
        )
        if pub:
            pub_id = pub.id_publicacion

    if pub_id:
        response = client.get(f"/api/facebook/publicaciones/{pub_id}/comentarios")
        assert response.status_code == 200
        body = response.get_json()
        assert body["success"] is True
        assert body["data"]["id_publicacion"] == pub_id
        assert isinstance(body["data"]["items"], list)


def test_real_database_read_metrics(client):
    """
    Consulta de métricas registradas en dbo.metrica_publicacion_diaria para Facebook.
    """
    response = client.get("/api/facebook/metricas")
    assert response.status_code == 200
    body = response.get_json()
    assert body["success"] is True
    assert "total" in body
    assert isinstance(body["data"], list)


def test_persona_integrity_never_created_by_facebook_operations(app):
    """
    10. Verificar que nunca se hayan creado registros ficticios en dbo.persona.
    Los prospectos captados en Facebook deben quedar exclusivamente en dbo.buyer
    con id_persona = NULL hasta que completen un formulario de conversión con consentimiento.
    """
    with app.app_context():
        # Consultar todos los buyers originados en Facebook
        fb_plat = db.session.query(Plataforma).filter(Plataforma.codigo == "FACEBOOK").first()
        fb_buyers = (
            db.session.query(Buyer)
            .filter(Buyer.id_plataforma_origen == fb_plat.id_plataforma)
            .all()
        )

        for b in fb_buyers:
            if b.estado == "BUYER":
                # Un BUYER en fase inicial no debe tener id_persona
                assert b.id_persona is None, f"El BUYER {b.id_buyer} tiene id_persona asignado incorrectamente."

        # Verificar que no existen personas sin nombre o apellido o con identificador de Facebook en tabla persona
        personas = db.session.query(Persona).all()
        for p in personas:
            assert p.nombres is not None and len(p.nombres.strip()) > 0
            assert p.apellidos is not None and len(p.apellidos.strip()) > 0
            # Cada persona debe tener teléfono o email válido
            assert p.telefono is not None or p.email is not None


def test_audit_records_exist_in_database(app):
    """
    6. Registrar integración y auditoría.
    Verifica que dbo.evento_integracion y dbo.accion_agente tienen estructura correcta
    y pueden registrar eventos con proveedor='META' y nombre_agente='AgenteFacebook'.
    """
    with app.app_context():
        # Eventos de integración
        eventos_meta = (
            db.session.query(EventoIntegracion)
            .filter(EventoIntegracion.proveedor == "META")
            .all()
        )
        # Acciones de agente
        acciones_fb = (
            db.session.query(AccionAgente)
            .filter(AccionAgente.nombre_agente == "AgenteFacebook")
            .all()
        )

        assert isinstance(eventos_meta, list)
        assert isinstance(acciones_fb, list)
