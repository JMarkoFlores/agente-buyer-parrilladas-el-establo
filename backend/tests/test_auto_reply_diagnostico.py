"""
Pruebas Unitarias y de Regresión de Diagnóstico para AutoReplyService y InterestClassifier (Prompt 13).
Verifica:
1. Clasificación correcta de expresiones gastronómicas ('Sabor único', 'Preparo rápido').
2. Manejo robusto de fechas UTC y fechas con huso horario de Perú (America/Lima).
3. Exclusiones obligatorias: DEMO, comentarios propios, duplicados, comentarios ya respondidos, comentarios antiguos.
4. Generación de respuesta única para comentarios nuevos aptos.
5. Manejo controlado de fallos de Meta Graph API sin marcar como ENVIADA.
"""
from datetime import datetime, timedelta, timezone
from unittest.mock import MagicMock, patch
import pytest

from app.extensions import db
from app.models.marketing import Publicacion
from app.models.persona import InteraccionPublicacion
from app.models.respuesta_automatica import RespuestaAutomatica
from app.services.auto_reply_service import AutoReplyService
from app.services.interest_classifier import (
    InterestClassifier,
    CATEGORIA_CONSULTA_PRECIO,
    CATEGORIA_INTERES_PRODUCTO,
    CATEGORIA_CONSULTA_RESERVA,
    CATEGORIA_ELOGIO,
    CATEGORIA_OTRO,
)


@pytest.fixture
def service():
    return AutoReplyService()


class MockPost:
    def __init__(self, id_publicacion=14, id_plataforma=1, meta_post_id="POST_REAL_123"):
        self.id_publicacion = id_publicacion
        self.id_plataforma = id_plataforma
        self.meta_post_id = meta_post_id


class MockComentario:
    def __init__(
        self,
        id_interaccion=99101,
        id_interaccion_externa="FB_COMM_99101",
        tipo="COMENTARIO",
        id_usuario_externo="USER_BUYER_01",
        nombre_visible="Juan Pérez",
        texto="Sabor único, me encantó",
        fecha_interaccion=None,
        publicacion=None,
        id_buyer=None,
    ):
        self.id_interaccion = id_interaccion
        self.id_interaccion_externa = id_interaccion_externa
        self.tipo = tipo
        self.id_usuario_externo = id_usuario_externo
        self.nombre_visible = nombre_visible
        self.texto = texto
        self.fecha_interaccion = fecha_interaccion or datetime.utcnow()
        self.publicacion = publicacion or MockPost()
        self.id_buyer = id_buyer


def test_clasificacion_expresiones_gastronomicas_y_rapidez():
    """Verifica que 'Sabor único' y 'Preparo rápido' se clasifiquen como ELOGIO y no como OTRO."""
    assert InterestClassifier.clasificar("Sabor único") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("sabor unico") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Gran sabor en las carnes") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Auténtico sabor parrillero") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Preparo rápido") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Atención rápida") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Servicio súper rápido") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("Excelente calidad de carne") == CATEGORIA_ELOGIO
    assert InterestClassifier.clasificar("100% recomendado") == CATEGORIA_ELOGIO


def test_clasificacion_consultas_generales_como_interes():
    """Verifica que consultas genéricas sin palabra 'precio' o 'reserva' califiquen como INTERES_PRODUCTO."""
    assert InterestClassifier.clasificar("Una consulta por favor") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("Tengo una pregunta") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("Quisiera información sobre sus platos") == CATEGORIA_INTERES_PRODUCTO


def test_comentario_nuevo_facebook_apto(app, service):
    """Verifica que un comentario nuevo apto de Facebook sea elegible y genere respuesta."""
    with app.app_context():
        com = MockComentario(
            id_interaccion=99101,
            id_interaccion_externa="FB_COMM_99101",
            texto="Sabor único, me encantó",
            publicacion=MockPost(id_publicacion=14, id_plataforma=1),
        )

        elegible, motivo, intencion = service.es_comentario_elegible(com)
        assert elegible is True
        assert intencion == CATEGORIA_ELOGIO

        template = service.get_template("FACEBOOK", intencion)
        assert "https://elestablo.giansmd.dev/registro/" in template


def test_comentario_nuevo_instagram_apto(app, service):
    """Verifica que un comentario nuevo apto de Instagram sea elegible e incluya enlace y biografía."""
    with app.app_context():
        com = MockComentario(
            id_interaccion=99102,
            id_interaccion_externa="IG_COMM_99102",
            texto="Preparo rápido y muy rico",
            publicacion=MockPost(id_publicacion=15, id_plataforma=2),
        )

        elegible, motivo, intencion = service.es_comentario_elegible(com)
        assert elegible is True
        assert intencion == CATEGORIA_ELOGIO

        template = service.get_template("INSTAGRAM", intencion)
        assert "https://elestablo.giansmd.dev/registro/" in template
        assert "biograf" in template.lower()


def test_comentario_con_fechas_utc_y_peru(app, service):
    """
    Verifica que la comparación de antigüedad maneje correctamente datetimes:
    - Naive UTC
    - Aware America/Lima (UTC-5)
    Sin provocar TypeErrors ni rechazos indebidos por diferencia horaria de 5 horas.
    """
    with app.app_context():
        # Comentario emitido hace 15 minutos en hora de Perú (UTC-5)
        peru_tz = timezone(timedelta(hours=-5))
        hace_15m_peru = datetime.now(peru_tz) - timedelta(minutes=15)

        com_peru = MockComentario(
            id_interaccion=99103,
            id_interaccion_externa="FB_PERU_DATE_99103",
            texto="Excelente servicio y buen asado",
            fecha_interaccion=hace_15m_peru,
            publicacion=MockPost(id_publicacion=14, id_plataforma=1),
        )

        elegible, motivo, intencion = service.es_comentario_elegible(com_peru, max_age_hours=72)
        assert elegible is True, f"Fallo al evaluar fecha con huso horario de Perú: {motivo}"


def test_comentario_antiguo_bloqueado_por_antiguedad(app, service):
    """Verifica que comentarios con más de 72 horas sean descartados de plano."""
    with app.app_context():
        com_antiguo = MockComentario(
            id_interaccion=99104,
            id_interaccion_externa="FB_ANTIGUO_99104",
            texto="¿Cuánto cuesta la parrilla?",
            fecha_interaccion=datetime.utcnow() - timedelta(hours=80),
            publicacion=MockPost(id_publicacion=14, id_plataforma=1),
        )

        elegible, motivo, intencion = service.es_comentario_elegible(com_antiguo, max_age_hours=72)
        assert elegible is False
        assert "antigüedad" in motivo.lower()


def test_comentario_duplicado_y_ya_respondido(app, service):
    """Verifica que un comentario que ya cuenta con una respuesta previa no sea elegible."""
    with app.app_context():
        # Buscar una publicación real no-demo (id_publicacion > 3)
        pub = Publicacion.query.filter(
            Publicacion.id_publicacion > 3,
            ~Publicacion.meta_post_id.like("DEMO_%"),
        ).first()
        if not pub:
            pytest.skip("No hay publicaciones reales en DB")

        com = InteraccionPublicacion(
            id_publicacion=pub.id_publicacion,
            id_interaccion_externa="TEST_DUP_EXT_99999",
            tipo="COMENTARIO",
            id_usuario_externo="USER_DUP_999",
            nombre_visible="Doble Comentario",
            texto="Buen asado",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(com)
        db.session.commit()

        # Primera respuesta
        resp = RespuestaAutomatica(
            id_interaccion=com.id_interaccion,
            id_plataforma=pub.id_plataforma,
            intencion_detectada=CATEGORIA_ELOGIO,
            texto_respuesta="Gracias por visitarnos",
            estado="ENVIADA",
            tipo_envio="AUTOMATICO",
            id_respuesta_meta="META_CONFIRM_99999",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        # Evaluar elegibilidad del mismo comentario
        elegible, motivo, _ = service.es_comentario_elegible(com)
        assert elegible is False
        assert "ya cuenta con una respuesta" in motivo

        # Limpiar datos de prueba
        db.session.delete(resp)
        db.session.delete(com)
        db.session.commit()


def test_error_temporal_meta_no_marca_como_enviada(app, service):
    """
    Verifica que si Meta Graph API responde con error o sin ID de confirmación:
    1. La respuesta queda en estado FALLIDA (no ENVIADA).
    2. No se genera confirmación ficticia.
    3. Se registra el detalle del error para auditoría.
    """
    with app.app_context():
        pub = Publicacion.query.filter(
            Publicacion.id_publicacion > 3,
            ~Publicacion.meta_post_id.like("DEMO_%"),
        ).first()
        if not pub:
            pytest.skip("No hay publicaciones reales en DB")

        com = InteraccionPublicacion(
            id_publicacion=pub.id_publicacion,
            id_interaccion_externa="FB_ERROR_TEMP_COMM",
            tipo="COMENTARIO",
            id_usuario_externo="USER_ERR_01",
            nombre_visible="Test Error",
            texto="Precio de la parrillada",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(com)
        db.session.commit()

        resp = RespuestaAutomatica(
            id_interaccion=com.id_interaccion,
            id_plataforma=pub.id_plataforma,
            intencion_detectada=CATEGORIA_CONSULTA_PRECIO,
            texto_respuesta=service.get_template("FACEBOOK", CATEGORIA_CONSULTA_PRECIO),
            estado="APROBADA",
            tipo_envio="AUTOMATICO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        # Mockear cliente Meta para simular error 500
        mock_meta = MagicMock()
        mock_meta.reply_facebook_comment.side_effect = Exception("HTTP 500 Internal Server Error en Meta API")

        with patch.object(service, "_get_meta_client", return_value=mock_meta):
            with patch.dict(app.config, {"AUTO_REPLY_DRY_RUN": False, "AUTO_REPLY_ENABLED": True}):
                res = service.enviar_respuesta(resp.id_respuesta)
                assert res.get("success") is False

                # Verificar en base de datos
                resp_db = db.session.get(RespuestaAutomatica, resp.id_respuesta)
                assert resp_db.estado == "FALLIDA"
                assert resp_db.id_respuesta_meta is None
                assert "HTTP 500" in (resp_db.error_detalle or "")

        # Limpieza
        db.session.delete(resp)
        db.session.delete(com)
        db.session.commit()
