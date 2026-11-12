"""
Pruebas automatizadas de los endpoints de Landing Page:
- /api/landing/categorias
- /api/landing/carta
- /api/landing/productos
- /api/landing/platos-favoritos
- /api/landing/visitas
- /api/landing/eventos
- /api/landing/registros (Conversión BUYER -> LEAD)
- /api/landing/estadisticas
"""
import uuid
from flask.testing import FlaskClient


def test_get_landing_categorias(client: FlaskClient):
    res = client.get("/api/landing/categorias")
    assert res.status_code == 200
    data = res.get_json()
    assert data["success"] is True
    assert len(data["data"]) == 9
    cat_ids = [c["id"] for c in data["data"]]
    assert "res" in cat_ids
    assert "cerdo" in cat_ids
    assert "combos" in cat_ids
    assert "vinos" in cat_ids


def test_get_landing_carta(client: FlaskClient):
    res = client.get("/api/landing/carta")
    assert res.status_code == 200
    data = res.get_json()
    assert data["success"] is True
    assert len(data["data"]) == 9
    # Contar total de items en todas las categorías
    total_items = sum(len(c["items"]) for c in data["data"])
    assert total_items == 146


def test_get_landing_platos_favoritos(client: FlaskClient):
    res = client.get("/api/landing/platos-favoritos")
    assert res.status_code == 200
    data = res.get_json()
    assert data["success"] is True
    assert data["total"] == 43
    # Validar que no hay bebidas ni vinos
    for item in data["data"]:
        assert item["id_categoria"] not in ("bebidas", "vinos", "acompanamientos")


def test_post_landing_visita_y_evento(client: FlaskClient):
    token_vis = str(uuid.uuid4())
    # 1. Registrar visita
    res_visita = client.post(
        "/api/landing/visitas",
        json={
            "token_visitante": token_vis,
            "dispositivo_tipo": "ESCRITORIO",
            "utm_source": "test_source",
            "utm_campaign": "test_campaign",
        },
    )
    assert res_visita.status_code == 201
    vis_data = res_visita.get_json()
    assert vis_data["success"] is True
    assert "id_visita" in vis_data
    id_visita = vis_data["id_visita"]

    # 2. Registrar evento
    res_evento = client.post(
        "/api/landing/eventos",
        json={
            "id_visita": id_visita,
            "tipo": "CLIC_CARTA",
            "detalle": "Test clic carta",
        },
    )
    assert res_evento.status_code == 201
    assert res_evento.get_json()["success"] is True

    # Limpieza inmediata de prueba para prevenir contaminación (Prompt 19)
    with client.application.app_context():
        from app.extensions import db
        from app.models.web import VisitaWeb, EventoWeb, VisitanteWeb
        EventoWeb.query.filter_by(id_visita=id_visita).delete()
        VisitaWeb.query.filter_by(id_visita=id_visita).delete()
        VisitanteWeb.query.filter_by(token_visitante=token_vis).delete()
        db.session.commit()


def test_post_landing_registro_captacion_lead(client: FlaskClient):
    token_vis = str(uuid.uuid4())
    payload = {
        "persona": {
            "nombres": "Valeria",
            "apellidos": "Castro Morales",
            "telefono": "923456789",
            "email": "valeria.castro@test.com",
            "fecha_nacimiento": "1994-08-20",
            "consentimiento_datos": True,
            "consentimiento_marketing": True,
        },
        "formulario": {
            "id_plataforma_origen": "LANDING_PAGE",
            "id_publicacion_origen": None,
            "producto_favorito": "Asado de tira de res",
            "fecha_envio": "2026-11-12T04:10:00Z",
            "acepta_politica_datos": True,
            "acepta_marketing": True,
        },
        "origen": {
            "token_visitante": token_vis,
            "token_visita": str(uuid.uuid4()),
            "utm_source": "instagram",
            "utm_campaign": "promo_verano",
            "utm_content": None,
            "fbclid": None,
            "id_publicacion": None,
        },
    }

    res = client.post("/api/landing/registros", json=payload)
    assert res.status_code == 201
    data = res.get_json()
    assert data["success"] is True
    assert data["data"]["fase"] == "LEAD"
    assert "id_buyer" in data["data"]
    assert "id_formulario" in data["data"]

    # Limpieza inmediata de prueba para prevenir contaminación (Prompt 19)
    with client.application.app_context():
        from app.extensions import db
        from app.models.persona import Persona, Buyer
        from app.models.conversion import FormularioCaptacion, LeadConversion, HistorialFases
        from app.models.web import VisitaWeb, VisitanteWeb, EventoWeb

        valeria = Persona.query.filter_by(email="valeria.castro@test.com").first()
        if valeria:
            p_id = valeria.id_persona
            buyer_ids = [b.id_buyer for b in Buyer.query.filter_by(id_persona=p_id).all()]
            HistorialFases.query.filter_by(id_persona=p_id).delete(synchronize_session=False)
            LeadConversion.query.filter_by(id_persona=p_id).delete(synchronize_session=False)
            FormularioCaptacion.query.filter_by(id_persona=p_id).delete(synchronize_session=False)
            if buyer_ids:
                VisitaWeb.query.filter(VisitaWeb.id_buyer.in_(buyer_ids)).update({"id_buyer": None}, synchronize_session=False)
            Buyer.query.filter_by(id_persona=p_id).delete(synchronize_session=False)
            VisitanteWeb.query.filter_by(id_persona=p_id).update({"id_persona": None}, synchronize_session=False)
            Persona.query.filter_by(id_persona=p_id).delete(synchronize_session=False)

        vis = VisitanteWeb.query.filter_by(token_visitante=token_vis).first()
        if vis:
            vis_id = vis.id_visitante
            visita_ids = [v.id_visita for v in VisitaWeb.query.filter_by(id_visitante=vis_id).all()]
            if visita_ids:
                EventoWeb.query.filter(EventoWeb.id_visita.in_(visita_ids)).delete(synchronize_session=False)
                FormularioCaptacion.query.filter(FormularioCaptacion.id_visita.in_(visita_ids)).update({"id_visita": None}, synchronize_session=False)
                VisitaWeb.query.filter(VisitaWeb.id_visita.in_(visita_ids)).delete(synchronize_session=False)
            VisitanteWeb.query.filter_by(id_visitante=vis_id).delete(synchronize_session=False)
        db.session.commit()


def test_get_landing_estadisticas(client: FlaskClient):
    res = client.get("/api/landing/estadisticas")
    assert res.status_code == 200
    data = res.get_json()
    assert data["success"] is True
    assert "resumen" in data
    assert data["resumen"]["total_visitas"] >= 1
    # Métricas Prompt 18
    assert "visitas_landing" in data["resumen"]
    assert "visitantes_landing" in data["resumen"]
    assert "visualizaciones_carta" in data["resumen"]
    assert "visitantes_carta" in data["resumen"]
    assert "formularios" in data["resumen"]
    assert "leads" in data["resumen"]
    assert "conversion" in data["resumen"]
    assert "visitas_por_dia" in data
    assert "formularios_recientes" in data


def test_vista_carta_idempotency(client: FlaskClient):
    token_vis = str(uuid.uuid4())
    res_vis = client.post(
        "/api/landing/visitas",
        json={"token_visitante": token_vis, "dispositivo_tipo": "ESCRITORIO", "ruta": "/carta/"},
    )
    id_visita = res_vis.get_json()["id_visita"]

    # Primer registro de VISTA_CARTA
    res1 = client.post(
        "/api/landing/eventos",
        json={"id_visita": id_visita, "tipo": "VISTA_CARTA", "ruta": "/carta/"},
    )
    assert res1.status_code == 201
    assert res1.get_json()["success"] is True

    # Segundo registro dentro de la ventana de 4s (debe ser idempotente)
    res2 = client.post(
        "/api/landing/eventos",
        json={"id_visita": id_visita, "tipo": "VISTA_CARTA", "ruta": "/carta/"},
    )
    assert res2.status_code == 200
    assert res2.get_json()["idempotente"] is True

    # Limpieza inmediata de prueba para prevenir contaminación (Prompt 19)
    with client.application.app_context():
        from app.extensions import db
        from app.models.web import VisitaWeb, EventoWeb, VisitanteWeb
        EventoWeb.query.filter_by(id_visita=id_visita).delete()
        VisitaWeb.query.filter_by(id_visita=id_visita).delete()
        VisitanteWeb.query.filter_by(token_visitante=token_vis).delete()
        db.session.commit()


def test_get_landing_estadisticas_periodos(client: FlaskClient):
    for p in ["hoy", "7dias", "30dias", "todo"]:
        res = client.get(f"/api/landing/estadisticas?periodo={p}")
        assert res.status_code == 200
        data = res.get_json()
        assert data["success"] is True
        assert "resumen" in data
        assert "conversion_detalle" in data["resumen"]


def test_detalles_endpoints_and_masking(client: FlaskClient):
    # 1. Visitas
    r_visitas = client.get("/api/landing/detalles/visitas?page=1&page_size=5")
    assert r_visitas.status_code == 200
    assert r_visitas.get_json()["success"] is True

    # 2. Visitantes
    r_visitantes = client.get("/api/landing/detalles/visitantes?page=1&page_size=5")
    assert r_visitantes.status_code == 200
    assert r_visitantes.get_json()["success"] is True

    # 3. Visualizaciones Carta
    r_vc = client.get("/api/landing/detalles/visualizaciones-carta?page=1&page_size=5")
    assert r_vc.status_code == 200
    assert r_vc.get_json()["success"] is True

    # 4. Visitantes Carta
    r_vc_vis = client.get("/api/landing/detalles/visitantes-carta?page=1&page_size=5")
    assert r_vc_vis.status_code == 200
    assert r_vc_vis.get_json()["success"] is True

    # 5. Formularios - Sin autenticación (enmascarado)
    r_form_unauth = client.get("/api/landing/detalles/formularios?page=1&page_size=5")
    assert r_form_unauth.status_code == 200
    data_unauth = r_form_unauth.get_json()
    assert data_unauth["success"] is True
    if len(data_unauth["items"]) > 0:
        item = data_unauth["items"][0]
        assert "***" in item["telefono"] or item["telefono"] == ""

    # Formularios - Con autenticación Admin
    r_form_auth = client.get(
        "/api/landing/detalles/formularios?page=1&page_size=5",
        headers={"X-Admin-Token": "establo_secret_admin_2026"},
    )
    assert r_form_auth.status_code == 200
    assert r_form_auth.get_json()["success"] is True

    # 6. Leads
    r_leads = client.get("/api/landing/detalles/leads?page=1&page_size=5")
    assert r_leads.status_code == 200
    assert r_leads.get_json()["success"] is True

