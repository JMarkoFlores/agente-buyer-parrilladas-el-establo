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


def test_get_landing_estadisticas(client: FlaskClient):
    res = client.get("/api/landing/estadisticas")
    assert res.status_code == 200
    data = res.get_json()
    assert data["success"] is True
    assert "resumen" in data
    assert data["resumen"]["total_visitas"] >= 1
    assert "visitas_por_dia" in data
    assert "formularios_recientes" in data
