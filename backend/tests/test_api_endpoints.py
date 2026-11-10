"""
Pruebas de los endpoints REST del backend:
- /api/plataformas
- /api/productos
- /api/campanas
- /api/publicaciones
- /api/buyers
- /api/estadisticas/resumen
"""


def test_get_plataformas(client):
    """4. Se pueden leer las plataformas existentes en la BD."""
    response = client.get("/api/plataformas")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    plataformas = body.get("data")
    assert isinstance(plataformas, list)
    assert len(plataformas) == 4

    codigos = [p["codigo"] for p in plataformas]
    assert "FACEBOOK" in codigos
    assert "INSTAGRAM" in codigos
    assert "LANDING_PAGE" in codigos
    assert "WHATSAPP" in codigos


def test_get_plataforma_by_id(client):
    """Consulta de plataforma por ID existente y no existente."""
    response = client.get("/api/plataformas/1")
    assert response.status_code == 200
    body = response.get_json()
    assert body["data"]["codigo"] == "FACEBOOK"

    # ID no existente
    not_found = client.get("/api/plataformas/9999")
    assert not_found.status_code == 404
    assert not_found.get_json()["success"] is False


def test_get_productos(client):
    """5. Se pueden leer los productos gastronómicos de la carta."""
    response = client.get("/api/productos")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    productos = body.get("data")
    assert isinstance(productos, list)
    assert len(productos) >= 8

    # Verificar estructura del producto
    nombres = [p["nombre"] for p in productos]
    assert "Picaña a la Parrilla" in nombres
    assert "Bife Ancho" in nombres
    assert "Chicha Morada" in nombres


def test_get_productos_filter_categoria(client):
    """Filtro de productos por categoría."""
    response = client.get("/api/productos?categoria=BEBIDA")
    assert response.status_code == 200
    productos = response.get_json().get("data")
    assert len(productos) == 2
    for p in productos:
        assert p["categoria"] == "BEBIDA"


def test_get_campanas(client):
    """6. Se pueden leer las campañas publicitarias."""
    response = client.get("/api/campanas")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    campanas = body.get("data")
    assert isinstance(campanas, list)
    assert len(campanas) == 2

    nombres = [c["nombre"] for c in campanas]
    assert "Promoción picaña noviembre" in nombres
    assert "Sangría y parrilladas" in nombres


def test_get_publicaciones(client):
    """7. Se pueden consultar publicaciones."""
    response = client.get("/api/publicaciones")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    publicaciones = body.get("data")
    assert isinstance(publicaciones, list)
    assert len(publicaciones) == 3

    post_ids = [p["meta_post_id"] for p in publicaciones]
    assert "DEMO_FB_POST_01" in post_ids
    assert "DEMO_IG_POST_01" in post_ids


def test_get_buyers(client):
    """7. Se pueden consultar BUYERS y prospectos captados."""
    response = client.get("/api/buyers")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    assert body.get("total") == 5

    items = body.get("items")
    assert isinstance(items, list)
    assert len(items) == 5

    estados = {b["estado"] for b in items}
    assert "BUYER" in estados
    assert "CONVERTIDO_LEAD" in estados


def test_get_buyer_by_id(client):
    """Consulta de BUYER por ID."""
    response = client.get("/api/buyers/1")
    assert response.status_code == 200
    body = response.get_json()
    assert body["data"]["id_buyer"] == 1
    assert body["data"]["estado"] == "CONVERTIDO_LEAD"
    assert body["data"]["persona"]["nombres"] == "Ana"

    # ID no existente
    not_found = client.get("/api/buyers/9999")
    assert not_found.status_code == 404
    assert not_found.get_json()["success"] is False


def test_get_estadisticas_resumen(client):
    """8. Comprobación del endpoint de analítica y resumen del embudo."""
    response = client.get("/api/estadisticas/resumen")
    assert response.status_code == 200
    assert response.content_type == "application/json"

    body = response.get_json()
    assert body.get("success") is True
    data = body.get("data")
    assert "embudo_buyer" in data
    assert "marketing" in data
    assert "canales_interaccion" in data
    assert "buyers_por_plataforma" in data

    embudo = data["embudo_buyer"]
    assert embudo["total_buyers"] == 5
    assert embudo["buyers_convertidos_lead"] == 3
    assert embudo["tasa_conversion_lead_porcentaje"] == 60.0


def test_custom_404_json(client):
    """Manejo de rutas no existentes devuelve JSON estructurado."""
    response = client.get("/api/ruta_inexistente")
    assert response.status_code == 404
    assert response.content_type == "application/json"
    body = response.get_json()
    assert body["success"] is False
    assert "Recurso no encontrado" in body["error"]
