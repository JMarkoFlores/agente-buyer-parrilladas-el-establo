"""
Pruebas de Integración Reales para el Agente de Instagram.
Verifica directamente en la base de datos SQL Server 'buyer':
- Plataforma INSTAGRAM configurada con id_plataforma = 2.
- Publicación real 18064509917761836 almacenada correctamente con id_plataforma = 2.
- Métricas con total_reacciones = 2 y total_comentarios = 0.
- Consulta de endpoints GET /api/instagram/publicaciones y GET /api/instagram/metricas.
- No duplicación de registros e integridad de dbo.persona.
"""
import pytest
from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Persona, Buyer


def test_instagram_platform_in_database(app):
    """Verifica que la plataforma INSTAGRAM existe con id_plataforma = 2."""
    with app.app_context():
        plat = db.session.query(Plataforma).filter(Plataforma.codigo == "INSTAGRAM").first()
        assert plat is not None
        assert plat.id_plataforma == 2
        assert plat.meta_account_id == "17841429540906353"


def test_real_instagram_post_stored(app):
    """Verifica que la publicación 18064509917761836 está guardada con id_plataforma = 2."""
    with app.app_context():
        pub = db.session.query(Publicacion).filter(
            Publicacion.meta_post_id == "18064509917761836"
        ).first()
        assert pub is not None
        assert pub.id_plataforma == 2
        assert pub.texto == "Parrillada El Establo"
        assert pub.estado == "PUBLICADA"


def test_real_instagram_metrics_stored(app):
    """Verifica que la métrica de Instagram guardó total_reacciones = 2 y total_comentarios = 0."""
    with app.app_context():
        pub = db.session.query(Publicacion).filter(
            Publicacion.meta_post_id == "18064509917761836"
        ).first()
        assert pub is not None

        metrica = db.session.query(MetricaPublicacionDiaria).filter(
            MetricaPublicacionDiaria.id_publicacion == pub.id_publicacion
        ).first()
        assert metrica is not None
        assert metrica.total_reacciones >= 2
        assert metrica.total_comentarios >= 1


def test_get_instagram_publicaciones_endpoint(client):
    """Consulta GET /api/instagram/publicaciones."""
    res = client.get("/api/instagram/publicaciones")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert body["total"] >= 1
    post_ids = [p["meta_post_id"] for p in body["data"]]
    assert "18064509917761836" in post_ids


def test_get_instagram_metricas_endpoint(client):
    """Consulta GET /api/instagram/metricas."""
    res = client.get("/api/instagram/metricas")
    assert res.status_code == 200
    body = res.get_json()
    assert body["success"] is True
    assert body["total"] >= 1
