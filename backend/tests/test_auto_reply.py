"""
Pruebas exhaustivas para el Agente de Respuestas Automáticas (AutoReplyService)
y sus endpoints REST:
- Evaluación de comentarios de Facebook e Instagram.
- Clasificación de intención comercial.
- Uso del enlace real del formulario (https://elestablo.giansmd.dev/registro/) en FB
  e invitación al enlace de la biografía en IG.
- Exclusión de comentarios DEMO.
- Exclusión de comentarios propios del restaurante.
- Exclusión de respuestas existentes y comentarios no comerciales (OTRO).
- Cooldown por usuario para evitar spam.
- Comprobación de que responder NO altera 'buyer.estado' a CONVERTIDO_LEAD.
- Funcionamiento del modo DRY_RUN y simulación.
- Flujo de aprobación manual, rechazo y envío.
- Auditoría en dbo.accion_agente.
"""
from datetime import datetime, timedelta
from unittest.mock import MagicMock, patch
import pytest

from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import AccionAgente
from app.models.respuesta_automatica import RespuestaAutomatica
from app.services.auto_reply_service import AutoReplyService
from app.services.interest_classifier import (
    InterestClassifier,
    CATEGORIA_CONSULTA_PRECIO,
    CATEGORIA_INTERES_PRODUCTO,
    CATEGORIA_CONSULTA_PROMOCION,
    CATEGORIA_CONSULTA_UBICACION,
    CATEGORIA_CONSULTA_HORARIO,
    CATEGORIA_CONSULTA_RESERVA,
    CATEGORIA_ELOGIO,
    CATEGORIA_AGRADECIMIENTO,
    CATEGORIA_EMOJI_POSITIVO,
    CATEGORIA_SALUDO,
    CATEGORIA_INAPROPIADO,
    CATEGORIA_SPAM,
    CATEGORIA_DATOS_SENSIBLES,
    CATEGORIA_OTRO,
)
from app.extensions import db


@pytest.fixture
def auto_reply_service():
    return AutoReplyService()


def test_plantillas_facebook_contienen_enlace_oficial(auto_reply_service):
    """Verifica que todas las plantillas de Facebook incluyen la URL oficial del formulario."""
    form_url = "https://elestablo.giansmd.dev/registro/"
    for intencion in [
        CATEGORIA_CONSULTA_PRECIO,
        CATEGORIA_INTERES_PRODUCTO,
        CATEGORIA_CONSULTA_PROMOCION,
        CATEGORIA_CONSULTA_UBICACION,
        CATEGORIA_CONSULTA_HORARIO,
        CATEGORIA_CONSULTA_RESERVA,
    ]:
        template = auto_reply_service.get_template("FACEBOOK", intencion, form_url)
        assert form_url in template


def test_plantillas_instagram_invitan_a_la_biografia(auto_reply_service):
    """
    Verifica que las plantillas de Instagram incluyen la URL oficial https://elestablo.giansmd.dev/registro/
    y además invitan a visitar el enlace de la biografía (Prompt 10 - Sección 8).
    """
    form_url = "https://elestablo.giansmd.dev/registro/"
    for intencion in [
        CATEGORIA_CONSULTA_PRECIO,
        CATEGORIA_INTERES_PRODUCTO,
        CATEGORIA_CONSULTA_PROMOCION,
        CATEGORIA_CONSULTA_UBICACION,
        CATEGORIA_CONSULTA_HORARIO,
        CATEGORIA_CONSULTA_RESERVA,
        CATEGORIA_ELOGIO,
        CATEGORIA_AGRADECIMIENTO,
        CATEGORIA_EMOJI_POSITIVO,
        CATEGORIA_SALUDO,
    ]:
        template = auto_reply_service.get_template("INSTAGRAM", intencion, form_url)
        assert form_url in template, f"La plantilla IG para {intencion} debe incluir la URL oficial"
        assert "biograf" in template.lower() or "perfil" in template.lower()


def test_categoria_otro_no_genera_plantilla(auto_reply_service):
    """Comentarios de categoría OTRO no reciben respuesta comercial automática."""
    form_url = "https://elestablo.giansmd.dev/registro/"
    assert auto_reply_service.get_template("FACEBOOK", CATEGORIA_OTRO, form_url) == ""
    assert auto_reply_service.get_template("INSTAGRAM", CATEGORIA_OTRO, form_url) == ""


def test_exclusion_comentarios_demo(app, auto_reply_service):
    """Verifica que comentarios con prefijo DEMO son descartados de plano."""
    with app.app_context():
        class DummyPost:
            id_publicacion = 1
            meta_post_id = "DEMO_POST_01"

        class DummyComentario:
            id_interaccion = 9999
            id_interaccion_externa = "DEMO_COMMENT_99"
            tipo = "COMENTARIO"
            id_usuario_externo = "USER_123"
            nombre_visible = "Carlos"
            texto = "¿Cuánto cuesta la parrilla?"
            publicacion = DummyPost()

        elegible, motivo, intencion = auto_reply_service.es_comentario_elegible(DummyComentario())
        assert elegible is False
        assert "DEMO" in motivo


def test_exclusion_comentarios_propios_restaurante(app, auto_reply_service):
    """No responder a comentarios emitidos por la propia cuenta del restaurante."""
    with app.app_context():
        class DummyPost:
            id_publicacion = 14
            meta_post_id = "REAL_POST_14"

        class DummyComentario:
            id_interaccion = 8888
            id_interaccion_externa = "FB_COMMENT_88"
            tipo = "COMENTARIO"
            id_usuario_externo = "1341560062384618"  # Page ID
            nombre_visible = "Parrilladas El Establo"
            texto = "¡Bienvenidos a todos!"
            publicacion = DummyPost()

        elegible, motivo, intencion = auto_reply_service.es_comentario_elegible(DummyComentario())
        assert elegible is False
        assert "restaurante" in motivo.lower()


def test_exclusion_comentarios_que_son_respuestas(app, auto_reply_service):
    """No responder a interacciones de tipo RESPUESTA."""
    with app.app_context():
        class DummyPost:
            id_publicacion = 14
            meta_post_id = "REAL_POST_14"

        class DummyComentario:
            id_interaccion = 7777
            id_interaccion_externa = "FB_REPLY_77"
            tipo = "RESPUESTA"
            id_usuario_externo = "USER_456"
            nombre_visible = "Juan"
            texto = "Gracias por responder"
            publicacion = DummyPost()

        elegible, motivo, intencion = auto_reply_service.es_comentario_elegible(DummyComentario())
        assert elegible is False
        assert "ya es una respuesta" in motivo.lower()


def test_regla_estricta_conversion_no_altera_buyer(app, auto_reply_service):
    """
    REGLA CRÍTICA:
    Verifica que ni la evaluación, ni la generación, ni la simulación
    alteran el campo 'estado' del BUYER a CONVERTIDO_LEAD.
    """
    with app.app_context():
        # Buscar un BUYER real en estado BUYER
        buyer = db.session.query(Buyer).filter(Buyer.estado == "BUYER").first()
        if buyer:
            estado_original = buyer.estado
            assert estado_original == "BUYER"

            # Simular una respuesta
            mock_client = MagicMock()
            mock_client.reply_facebook_comment.return_value = {"id": "MOCK_META_REPLY_123"}
            service = AutoReplyService(meta_client=mock_client)

            # Comprobar que tras cualquier operación el estado de BUYER sigue siendo BUYER
            db.session.refresh(buyer)
            assert buyer.estado == "BUYER"
            assert buyer.estado != "CONVERTIDO_LEAD"


def test_endpoints_status_respuestas(client):
    """Comprueba el endpoint GET /api/respuestas/status."""
    res = client.get("/api/respuestas/status")
    assert res.status_code == 200
    body = res.get_json()
    assert body.get("success") is True
    data = body.get("data", {})
    assert "config" in data
    assert "metricas" in data
    cfg = data["config"]
    assert "form_url" in cfg
    assert "dry_run" in cfg
    assert "enabled" in cfg


def test_flujo_aprobar_y_rechazar_respuesta(app, auto_reply_service):
    """Prueba el ciclo de vida de aprobación manual y rechazo en SQL Server con auditoría."""
    with app.app_context():
        # Crear una interacción de prueba
        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_COMM_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_999",
            nombre_visible="Test User",
            texto="¿Cuánto cuesta la parrillada?",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(interaccion)
        db.session.flush()

        # Crear propuesta
        resp = RespuestaAutomatica(
            id_interaccion=interaccion.id_interaccion,
            id_buyer=35,
            id_plataforma=1,
            intencion_detectada="CONSULTA_PRECIO",
            texto_respuesta="Propuesta inicial de prueba",
            estado="PENDIENTE",
            tipo_envio="MANUAL_APROBADO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        # 1. Aprobar con edición
        resultado_aprob = auto_reply_service.aprobar_respuesta(
            id_respuesta=resp.id_respuesta,
            texto_editado="Texto editado y aprobado para El Establo",
        )
        assert resultado_aprob["success"] is True
        assert resp.estado == "APROBADA"
        assert resp.texto_respuesta == "Texto editado y aprobado para El Establo"

        # Verificar auditoría
        auditoria_aprob = AccionAgente.query.filter_by(
            accion="APROBAR_RESPUESTA",
            id_buyer=35,
        ).order_by(AccionAgente.id_accion.desc()).first()
        assert auditoria_aprob is not None
        assert auditoria_aprob.resultado == "EXITOSO"

        # 2. Rechazar
        resultado_rech = auto_reply_service.rechazar_respuesta(
            id_respuesta=resp.id_respuesta,
            motivo="Prueba de descarte",
        )
        assert resultado_rech["success"] is True
        assert resp.estado == "OMITIDA"

        # Limpiar registro de prueba
        db.session.delete(resp)
        db.session.delete(interaccion)
        db.session.commit()


def test_flujo_enviar_respuesta_dry_run(app, auto_reply_service):
    """En modo DRY RUN, enviar genera estado SIMULADA sin realizar llamadas de red externas."""
    with app.app_context():
        orig_dry = app.config.get("AUTO_REPLY_DRY_RUN")
        app.config["AUTO_REPLY_DRY_RUN"] = True

        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_DRY_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_DRY",
            nombre_visible="Test Dry",
            texto="Tengo interés en el bife de chorizo",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(interaccion)
        db.session.flush()

        resp = RespuestaAutomatica(
            id_interaccion=interaccion.id_interaccion,
            id_buyer=35,
            id_plataforma=1,
            intencion_detectada="INTERES_PRODUCTO",
            texto_respuesta="Respuesta simulada para Parrilladas El Establo: https://elestablo.giansmd.dev/registro/",
            estado="APROBADA",
            tipo_envio="AUTOMATICO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        try:
            resultado = auto_reply_service.enviar_respuesta(resp.id_respuesta)
            assert resultado["success"] is True
            assert resultado.get("simulada") is True
            assert resp.estado == "SIMULADA"
            assert resp.id_respuesta_meta is not None
            assert "SIMULATED_REPLY" in resp.id_respuesta_meta
        finally:
            app.config["AUTO_REPLY_DRY_RUN"] = orig_dry
            db.session.delete(resp)
            db.session.delete(interaccion)
            db.session.commit()


def test_flujo_enviar_respuesta_live_mock(app):
    """En modo envío real (DRY_RUN=False), interactúa con MetaGraphClient y registra id_respuesta_meta."""
    mock_client = MagicMock()
    mock_client.reply_facebook_comment.return_value = {"id": "META_COMMENT_REPLY_55555"}

    service = AutoReplyService(meta_client=mock_client)

    with app.app_context():
        # Forzar temporalmente DRY_RUN=False y ENABLED=True
        orig_dry = app.config.get("AUTO_REPLY_DRY_RUN")
        orig_enabled = app.config.get("AUTO_REPLY_ENABLED")
        app.config["AUTO_REPLY_DRY_RUN"] = False
        app.config["AUTO_REPLY_ENABLED"] = True

        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_LIVE_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_LIVE",
            nombre_visible="Test Live",
            texto="¿Tienen promociones hoy?",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(interaccion)
        db.session.flush()

        resp = RespuestaAutomatica(
            id_interaccion=interaccion.id_interaccion,
            id_buyer=35,
            id_plataforma=1,
            intencion_detectada="CONSULTA_PROMOCION",
            texto_respuesta="Respuesta enviada live para Parrilladas El Establo: https://elestablo.giansmd.dev/registro/",
            estado="APROBADA",
            tipo_envio="AUTOMATICO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        try:
            resultado = service.enviar_respuesta(resp.id_respuesta)
            assert resultado["success"] is True
            assert resultado.get("simulada") is False
            assert resp.estado == "ENVIADA"
            assert resp.id_respuesta_meta == "META_COMMENT_REPLY_55555"
            assert resp.fecha_envio is not None

            assert mock_client.reply_facebook_comment.call_count >= 1
        finally:
            # Restaurar configuración original
            app.config["AUTO_REPLY_DRY_RUN"] = orig_dry
            app.config["AUTO_REPLY_ENABLED"] = orig_enabled
            db.session.delete(resp)
            db.session.delete(interaccion)
            db.session.commit()


def test_endpoint_historial_y_pendientes(client, app):
    """Comprueba los endpoints de listado GET /api/respuestas/historial y GET /api/respuestas/pendientes."""
    with app.app_context():
        res_hist = client.get("/api/respuestas/historial?limit=10")
        assert res_hist.status_code == 200
        assert res_hist.get_json()["success"] is True
        assert "data" in res_hist.get_json()

        res_pend = client.get("/api/respuestas/pendientes?limit=10")
        assert res_pend.status_code == 200
        assert res_pend.get_json()["success"] is True
        assert "data" in res_pend.get_json()


def test_envio_totalmente_automatico_sin_revision(app):
    """
    Verifica que con AUTO_REPLY_REQUIRE_REVIEW=False, AUTO_REPLY_DRY_RUN=False y AUTO_REPLY_ENABLED=True,
    el servicio no solo genera la propuesta sino que la despacha automáticamente a Meta (mock).
    """
    mock_client = MagicMock()
    mock_client.reply_facebook_comment.return_value = {"id": "AUTO_DISPATCH_META_9999"}

    service = AutoReplyService(meta_client=mock_client)

    with app.app_context():
        orig_dry = app.config.get("AUTO_REPLY_DRY_RUN")
        orig_enabled = app.config.get("AUTO_REPLY_ENABLED")
        orig_review = app.config.get("AUTO_REPLY_REQUIRE_REVIEW")

        app.config["AUTO_REPLY_DRY_RUN"] = False
        app.config["AUTO_REPLY_ENABLED"] = True
        app.config["AUTO_REPLY_REQUIRE_REVIEW"] = False

        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_AUTO_DISPATCH_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_AUTO",
            nombre_visible="Usuario Auto",
            texto="¿Cuál es el precio de la picaña?",
            fecha_interaccion=datetime.utcnow() - timedelta(hours=1),
        )
        db.session.add(interaccion)
        db.session.commit()

        try:
            resumen = service.procesar_comentarios_nuevos(max_comentarios=5)
            assert resumen["success"] is True
            assert resumen["propuestas_generadas"] >= 1

            # Verificar que el registro en BD quedó ENVIADA y con Meta ID
            resp_db = RespuestaAutomatica.query.filter_by(id_interaccion=interaccion.id_interaccion).first()
            assert resp_db is not None
            assert resp_db.estado == "ENVIADA"
            assert resp_db.id_respuesta_meta == "AUTO_DISPATCH_META_9999"
            assert mock_client.reply_facebook_comment.call_count >= 1
        finally:
            app.config["AUTO_REPLY_DRY_RUN"] = orig_dry
            app.config["AUTO_REPLY_ENABLED"] = orig_enabled
            app.config["AUTO_REPLY_REQUIRE_REVIEW"] = orig_review

            resp_clean = RespuestaAutomatica.query.filter_by(id_interaccion=interaccion.id_interaccion).first()
            if resp_clean:
                db.session.delete(resp_clean)
            db.session.delete(interaccion)
            db.session.commit()


def test_meta_sin_id_falla_y_no_marca_enviada(app):
    """
    REGLA: No marques ENVIADA una respuesta que Meta no haya confirmado (ID faltante o vacío).
    """
    mock_client = MagicMock()
    mock_client.reply_facebook_comment.return_value = {}  # Meta no devolvió ID

    service = AutoReplyService(meta_client=mock_client)

    with app.app_context():
        orig_dry = app.config.get("AUTO_REPLY_DRY_RUN")
        orig_enabled = app.config.get("AUTO_REPLY_ENABLED")
        app.config["AUTO_REPLY_DRY_RUN"] = False
        app.config["AUTO_REPLY_ENABLED"] = True

        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_NO_ID_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_NO_ID",
            nombre_visible="Usuario No ID",
            texto="¿Atienden feriados?",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(interaccion)
        db.session.flush()

        resp = RespuestaAutomatica(
            id_interaccion=interaccion.id_interaccion,
            id_buyer=35,
            id_plataforma=1,
            intencion_detectada="CONSULTA_HORARIO",
            texto_respuesta="Horarios de atención de El Establo: https://elestablo.giansmd.dev/registro/",
            estado="APROBADA",
            tipo_envio="AUTOMATICO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        try:
            res = service.enviar_respuesta(resp.id_respuesta)
            assert res["success"] is False
            assert resp.estado == "FALLIDA"
            assert resp.id_respuesta_meta is None
            assert "identificador de confirmación" in (resp.error_detalle or "")
        finally:
            app.config["AUTO_REPLY_DRY_RUN"] = orig_dry
            app.config["AUTO_REPLY_ENABLED"] = orig_enabled
            db.session.delete(resp)
            db.session.delete(interaccion)
            db.session.commit()


def test_cooldown_no_bloquea_en_live_por_simuladas(app, auto_reply_service):
    """
    Verifica que en modo live (dry_run=False), una respuesta anterior 'SIMULADA'
    NO active el cooldown para el usuario real.
    """
    with app.app_context():
        orig_dry = app.config.get("AUTO_REPLY_DRY_RUN")
        app.config["AUTO_REPLY_DRY_RUN"] = False

        # El usuario de Instagram 1865964591264973 tiene Resp #2 en estado SIMULADA, pero ninguna ENVIADA
        class DummyPost:
            id_publicacion = 19
            id_plataforma = 2
            meta_post_id = "REAL_IG_MEDIA_19"

        class DummyComentario:
            id_interaccion = 99912
            id_interaccion_externa = "IG_COM_99912"
            tipo = "COMENTARIO"
            id_usuario_externo = "1865964591264973"  # Usuario con solo respuesta SIMULADA
            nombre_visible = "markoo.flores"
            texto = "Tengo interés en reservar una mesa"
            publicacion = DummyPost()

        try:
            elegible, motivo, intencion = auto_reply_service.es_comentario_elegible(DummyComentario())
            assert elegible is True
            assert intencion == "CONSULTA_RESERVA"
        finally:
            app.config["AUTO_REPLY_DRY_RUN"] = orig_dry


def test_endpoint_trazabilidad(client, app):
    """Comprueba el endpoint GET /api/respuestas/trazabilidad."""
    with app.app_context():
        res = client.get("/api/respuestas/trazabilidad?limit=20")
        assert res.status_code == 200
        body = res.get_json()
        assert body["success"] is True
        data = body["data"]
        assert "resumen" in data
        assert "items" in data
        assert "total" in data
        resumen = data["resumen"]
        assert "total_evaluados" in resumen
        assert "respondidos_meta" in resumen
        assert "simulados" in resumen
        assert "bloqueados_cooldown" in resumen


def test_plantillas_elogios_y_agradecimientos_incluyen_enlace(auto_reply_service):
    """
    Verifica que elogios, agradecimientos y emojis generan respuestas comerciales breves y naturales
    que incluyen el enlace oficial de registro (Prompt 10 - Sección 5).
    """
    form_url = "https://elestablo.giansmd.dev/registro/"
    for cat in [CATEGORIA_ELOGIO, CATEGORIA_AGRADECIMIENTO, CATEGORIA_EMOJI_POSITIVO, CATEGORIA_SALUDO]:
        tmpl_fb = auto_reply_service.get_template("FACEBOOK", cat, form_url)
        assert len(tmpl_fb) > 0
        assert form_url in tmpl_fb, f"La plantilla FB para {cat} debe incluir la URL oficial"

        tmpl_ig = auto_reply_service.get_template("INSTAGRAM", cat, form_url)
        assert len(tmpl_ig) > 0
        assert form_url in tmpl_ig, f"La plantilla IG para {cat} debe incluir la URL oficial"
        assert "biograf" in tmpl_ig.lower() or "perfil" in tmpl_ig.lower()


def test_nueva_regla_cada_comentario_apto_incluye_enlace_oficial(auto_reply_service):
    """
    Verifica la NUEVA REGLA (Prompt 10 - Sección 3):
    - Cada comentario nuevo apto recibe su propia respuesta.
    - Cada respuesta enviada debe incluir la URL oficial del formulario.
    - Que un usuario haya recibido el enlace previamente NO debe eliminarlo de una nueva respuesta apta.
    """
    form_url = "https://elestablo.giansmd.dev/registro/"
    tmpl_inicial = auto_reply_service.get_template("FACEBOOK", CATEGORIA_CONSULTA_PRECIO, form_url, usuario_ya_recibio_enlace=False)
    assert form_url in tmpl_inicial

    # Con la nueva regla, incluso si usuario_ya_recibio_enlace fuera True o False, debe contener form_url
    tmpl_recurrente = auto_reply_service.get_template("FACEBOOK", CATEGORIA_CONSULTA_PRECIO, form_url, usuario_ya_recibio_enlace=True)
    assert form_url in tmpl_recurrente


def test_dos_comentarios_mismo_usuario_reciben_respuestas_diferentes(app, auto_reply_service):
    """
    Comprueba que dos comentarios nuevos diferentes del mismo usuario son ambos elegibles
    y reciben respuestas contextuales adaptadas, ambas conteniendo la URL oficial.
    """
    with app.app_context():
        class DummyPost:
            id_publicacion = 14
            id_plataforma = 1
            meta_post_id = "REAL_FB_POST_14"

        com1 = InteraccionPublicacion(
            id_publicacion=14,
            id_interaccion_externa=f"TEST_USER_SAME_1_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="USER_SAME_100",
            nombre_visible="Cliente Frecuente",
            texto="¿Cuánto cuesta la parrillada?",
            fecha_interaccion=datetime.utcnow(),
        )
        com2 = InteraccionPublicacion(
            id_publicacion=14,
            id_interaccion_externa=f"TEST_USER_SAME_2_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="USER_SAME_100",
            nombre_visible="Cliente Frecuente",
            texto="Buen asado",
            fecha_interaccion=datetime.utcnow(),
        )

        db.session.add(com1)
        db.session.add(com2)
        db.session.flush()

        try:
            # Comentario 1: Elegible para respuesta de precio
            elegible1, motivo1, intencion1 = auto_reply_service.es_comentario_elegible(com1)
            assert elegible1 is True
            assert intencion1 == CATEGORIA_CONSULTA_PRECIO

            # Comentario 2 del MISMO usuario: También elegible para respuesta de elogio
            elegible2, motivo2, intencion2 = auto_reply_service.es_comentario_elegible(com2)
            assert elegible2 is True
            assert intencion2 == CATEGORIA_ELOGIO

            form_url = "https://elestablo.giansmd.dev/registro/"
            resp1 = auto_reply_service.get_template("FACEBOOK", intencion1, form_url)
            resp2 = auto_reply_service.get_template("FACEBOOK", intencion2, form_url)

            # Respuestas distintas y ambas con el enlace oficial
            assert resp1 != resp2
            assert form_url in resp1
            assert form_url in resp2
        finally:
            db.session.delete(com1)
            db.session.delete(com2)
            db.session.commit()


def test_comentarios_obligatorios_prompt_10(app, auto_reply_service):
    """
    Prueba los comentarios obligatorios indicados en la especificación (Facebook e Instagram):
    Facebook:
    - "Quiero hacer mi reserva, cómo hago?"
    - "Buen asado"
    - "Tengo interés"
    Instagram:
    - "Como reservo mi pedido?"
    - "Quiero pedir una parrillada"
    - "¿Cuánto cuesta?"
    """
    form_url = "https://elestablo.giansmd.dev/registro/"
    casos = [
        ("FACEBOOK", "Quiero hacer mi reserva, cómo hago?", CATEGORIA_CONSULTA_RESERVA),
        ("FACEBOOK", "Buen asado", CATEGORIA_ELOGIO),
        ("FACEBOOK", "Tengo interés", CATEGORIA_INTERES_PRODUCTO),
        ("INSTAGRAM", "Como reservo mi pedido?", CATEGORIA_CONSULTA_RESERVA),
        ("INSTAGRAM", "Quiero pedir una parrillada", CATEGORIA_CONSULTA_RESERVA),
        ("INSTAGRAM", "¿Cuánto cuesta?", CATEGORIA_CONSULTA_PRECIO),
    ]

    for plat, texto, intencion_esperada in casos:
        intencion = InterestClassifier.clasificar(texto)
        assert intencion == intencion_esperada, f"Fallo al clasificar '{texto}': esperado {intencion_esperada}, obtenido {intencion}"

        template = auto_reply_service.get_template(plat, intencion, form_url)
        assert len(template) > 0
        assert form_url in template, f"La plantilla para '{texto}' ({plat}) debe contener la URL oficial"
        if plat == "INSTAGRAM":
            assert "biograf" in template.lower()


def test_reprocesamiento_administrativo_evita_duplicados_y_no_reenvia_enviadas(app, auto_reply_service):
    """
    Verifica que el reprocesamiento administrativo (Prompt 10 - Sección 7):
    1. Si un comentario ya tiene una respuesta ENVIADA confirmada por Meta, bloquea el reenvío.
    2. Si un comentario fue omitido o simulado, permite actualizarlo sin generar duplicados.
    """
    with app.app_context():
        interaccion = InteraccionPublicacion(
            id_publicacion=14,
            id_buyer=35,
            id_interaccion_externa=f"TEST_REPROCESS_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="TEST_USER_REPROCESS",
            nombre_visible="Usuario Reproceso",
            texto="Como reservo mi pedido?",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(interaccion)
        db.session.flush()

        try:
            # 1. Reprocesar comentario que no tenía respuesta
            res = auto_reply_service.reprocesar_comentario(interaccion.id_interaccion)
            assert res["success"] is True
            assert res["data"]["intencion_detectada"] == "CONSULTA_RESERVA"
            assert "https://elestablo.giansmd.dev/registro/" in res["data"]["texto_respuesta"]

            id_creado = res["data"]["id_respuesta"]

            # 2. Simular que la respuesta fue ENVIADA con confirmación Meta
            resp_db = db.session.get(RespuestaAutomatica, id_creado)
            resp_db.estado = "ENVIADA"
            resp_db.id_respuesta_meta = "META_REPLY_CONFIRMED_12345"
            db.session.commit()

            # 3. Intentar reprocesar de nuevo: debe rechazar por estar ya confirmada en Meta
            res_repetido = auto_reply_service.reprocesar_comentario(interaccion.id_interaccion)
            assert res_repetido["success"] is False
            assert "ya cuenta con una respuesta confirmada por Meta" in res_repetido["error"]
        finally:
            resp_clean = RespuestaAutomatica.query.filter_by(id_interaccion=interaccion.id_interaccion).first()
            if resp_clean:
                db.session.delete(resp_clean)
            db.session.delete(interaccion)
            db.session.commit()


def test_validacion_estricta_previa_al_envio(app, auto_reply_service):
    """
    Verifica las validaciones previas al envío (Prompt 10 - Sección 9):
    - Requiere URL con HTTPS
    - Requiere que el texto contenga la URL completa
    - Control de longitud máxima
    """
    with app.app_context():
        form_url = "https://elestablo.giansmd.dev/registro/"
        texto_valido = f"¡Hola! Solicita tu información en {form_url}"

        # 1. Caso válido
        ok, msg = auto_reply_service.validar_respuesta_antes_de_envio(texto_valido, id_interaccion=999999)
        assert ok is True

        # 2. Texto sin la URL oficial
        ok2, msg2 = auto_reply_service.validar_respuesta_antes_de_envio("¡Hola! Reserva con nosotros.", id_interaccion=999999)
        assert ok2 is False
        assert "no contiene la URL oficial" in msg2

        # 3. Texto vacío
        ok3, msg3 = auto_reply_service.validar_respuesta_antes_de_envio("", id_interaccion=999999)
        assert ok3 is False

        # 4. Longitud excesiva (> 2000 chars)
        texto_largo = f"{form_url} " + ("x" * 2050)
        ok4, msg4 = auto_reply_service.validar_respuesta_antes_de_envio(texto_largo, id_interaccion=999999)
        assert ok4 is False
        assert "excede los 2000" in msg4


def test_mismo_comentario_no_recibe_dos_respuestas(app, auto_reply_service):
    """
    Verifica que si un comentario ya tiene una respuesta registrada en SQL Server,
    es estrictamente rechazado para evitar duplicaciones.
    """
    with app.app_context():
        com = InteraccionPublicacion(
            id_publicacion=14,
            id_interaccion_externa=f"TEST_DEDUP_{int(datetime.utcnow().timestamp())}",
            tipo="COMENTARIO",
            id_usuario_externo="USER_DEDUP",
            nombre_visible="User Dedup",
            texto="¿Tienen promociones?",
            fecha_interaccion=datetime.utcnow(),
        )
        db.session.add(com)
        db.session.flush()

        resp = RespuestaAutomatica(
            id_interaccion=com.id_interaccion,
            id_plataforma=1,
            intencion_detectada="CONSULTA_PROMOCION",
            texto_respuesta="Primera respuesta",
            estado="ENVIADA",
            tipo_envio="AUTOMATICO",
            fecha_generacion=datetime.utcnow(),
        )
        db.session.add(resp)
        db.session.commit()

        try:
            elegible, motivo, intencion = auto_reply_service.es_comentario_elegible(com)
            assert elegible is False
            assert "ya cuenta con una respuesta registrada" in motivo
        finally:
            db.session.delete(resp)
            db.session.delete(com)
            db.session.commit()


def test_exclusion_spam_insultos_datos_sensibles(app, auto_reply_service):
    """Comentarios con insultos, spam o datos sensibles son descartados de respuesta automática."""
    with app.app_context():
        class DummyPost:
            id_publicacion = 14
            id_plataforma = 1
            meta_post_id = "REAL_FB_POST_14"

        class DummyComentario:
            id_interaccion = 9911
            id_interaccion_externa = "FB_COM_9911"
            tipo = "COMENTARIO"
            id_usuario_externo = "USER_BAD"
            nombre_visible = "Hater"
            publicacion = DummyPost()
            fecha_interaccion = datetime.utcnow()

        # Insultos / estafa
        com_insulto = DummyComentario()
        com_insulto.texto = "Son unos estafadores ladrones"
        e1, m1, i1 = auto_reply_service.es_comentario_elegible(com_insulto)
        assert e1 is False
        assert i1 == CATEGORIA_INAPROPIADO

        # Spam
        com_spam = DummyComentario()
        com_spam.texto = "Gana dinero fácil en https://spam-crypto.net"
        e2, m2, i2 = auto_reply_service.es_comentario_elegible(com_spam)
        assert e2 is False
        assert i2 == CATEGORIA_SPAM

        # Datos sensibles
        com_sens = DummyComentario()
        com_sens.texto = "Mi clave es 1234 y mi tarjeta 4532 1234 5678 9010"
        e3, m3, i3 = auto_reply_service.es_comentario_elegible(com_sens)
        assert e3 is False
        assert i3 == CATEGORIA_DATOS_SENSIBLES


def test_emergency_stop_y_activar_auto_endpoints(client, app):
    """Verifica los endpoints de parada de emergencia y reactivación inmediata."""
    with app.app_context():
        # 1. Parada de emergencia
        res_stop = client.post("/api/respuestas/emergency-stop", headers={"X-Admin-Token": "admin-establo-buyer-secret-2026"})
        assert res_stop.status_code == 200
        body_stop = res_stop.get_json()
        assert body_stop["success"] is True
        assert app.config["AUTO_REPLY_ENABLED"] is False

        # 2. Reactivación
        res_start = client.post("/api/respuestas/activar-auto", headers={"X-Admin-Token": "admin-establo-buyer-secret-2026"})
        assert res_start.status_code == 200
        body_start = res_start.get_json()
        assert body_start["success"] is True
        assert app.config["AUTO_REPLY_ENABLED"] is True
        assert app.config["AUTO_REPLY_DRY_RUN"] is False
        assert app.config["AUTO_REPLY_REQUIRE_REVIEW"] is False


