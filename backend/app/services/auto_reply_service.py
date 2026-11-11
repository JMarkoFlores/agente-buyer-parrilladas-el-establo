"""
Servicio centralizado de Respuestas Automáticas a Comentarios de Facebook e Instagram.
Agente Inteligente Multicanal para la Captación y Conversión de BUYERS - Parrilladas El Establo.

Reglas esenciales:
1. Respetar políticas anti-spam: no responder al propio restaurante, no responder a respuestas existentes,
   no responder al mismo comentario dos veces (unicidad en SQL Server), aplicar cooldown por usuario.
2. Excluir estrictamente comentarios DEMO o sintéticos.
3. Diferenciar Facebook (enlace oficial https://elestablo.giansmd.dev/registro/) de Instagram
   (invitación al enlace de la biografía debido a que los enlaces en comentarios de IG no son clicables).
4. REGLA ESTRICTA DE CONVERSIÓN: Enviar una respuesta o registrar una interacción NO convierte al BUYER
   en LEAD. Tampoco lo convierte visitar la landing page. El estado 'buyer.estado' se mantiene intacto.
5. Control de estados: PENDIENTE, APROBADA, SIMULADA, ENVIANDO, ENVIADA, FALLIDA, OMITIDA, REQUIERE_REVISION.
"""
from __future__ import annotations

import logging
from datetime import datetime, timedelta, timezone
from typing import Any
from flask import current_app
from sqlalchemy import desc, or_, and_

from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import AccionAgente
from app.models.respuesta_automatica import RespuestaAutomatica
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
from app.services.data_filter_service import DataFilterService
from app.integrations.meta_client import (
    MetaGraphClient,
    MetaClientError,
    MetaAuthError,
    MetaPermissionError,
    MetaRateLimitError,
)

logger = logging.getLogger("auto_reply_service")


class AutoReplyService:
    """
    Servicio para evaluar, generar, aprobar y despachar respuestas comerciales contextuales.
    """

    # Identificadores conocidos del restaurante para evitar auto-respuestas en bucle
    KNOWN_RESTAURANT_IDS = {"1341560062384618", "17841429540906353"}
    KNOWN_RESTAURANT_NAMES = {"parrilladas el establo", "el establo", "parrilladas.elestablo"}

    def __init__(self, meta_client: MetaGraphClient | None = None):
        self._meta_client = meta_client

    def _get_meta_client(self) -> MetaGraphClient:
        """Obtiene o inicializa el cliente MetaGraphClient configurado con el Page Token."""
        if self._meta_client is not None:
            return self._meta_client

        token = current_app.config.get("META_PAGE_ACCESS_TOKEN", "")
        page_id = current_app.config.get("META_PAGE_ID", "")
        api_ver = current_app.config.get("META_GRAPH_VERSION", "v21.0")
        timeout = current_app.config.get("META_HTTP_TIMEOUT", 20)
        self._meta_client = MetaGraphClient(
            access_token=token,
            page_id=page_id,
            api_version=api_ver,
            timeout=timeout,
        )
        return self._meta_client

    # =========================================================================
    # Plantillas de Respuestas Comerciales Contextuales
    # =========================================================================

    CATEGORIAS_ELEGIBLES = {
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
    }

    def get_template(
        self,
        plataforma: str,
        intencion: str,
        form_url: str,
        usuario_ya_recibio_enlace: bool = False,
    ) -> str:
        """
        Retorna la plantilla adecuada según la intención detectada, la plataforma de origen
        y si el usuario ya recibió previamente el enlace oficial de registro.
        """
        plat = plataforma.upper()

        if plat == "FACEBOOK":
            if usuario_ya_recibio_enlace:
                # Si el usuario ya recibió el enlace recientemente, responder amablemente sin repetir el link como spam
                templates = {
                    CATEGORIA_CONSULTA_PRECIO: (
                        "¡Hola nuevamente! 🔥 Con gusto te informamos sobre nuestra carta y precios. "
                        "Como ya te compartimos el enlace de registro previamente, puedes revisar los detalles allí "
                        "o escribirnos por mensaje directo si deseas asistencia adicional. ¡Buen provecho!"
                    ),
                    CATEGORIA_INTERES_PRODUCTO: (
                        "¡Gracias nuevamente por tu interés! 🥩 Recuerda que puedes revisar todos nuestros cortes y detalles "
                        "en el formulario que te compartimos anteriormente. ¡Estamos atentos para atenderte!"
                    ),
                    CATEGORIA_CONSULTA_PROMOCION: (
                        "¡Hola de nuevo! 🔥 Recuerda que nuestras novedades y promociones especiales están disponibles "
                        "en el formulario que te enviamos previamente. ¡Te esperamos pronto en Parrilladas El Establo!"
                    ),
                    CATEGORIA_CONSULTA_UBICACION: (
                        "¡Hola nuevamente! 📍 Te esperamos en nuestro local con el auténtico sabor parrillero. "
                        "Toda la información de contacto y ubicación la encuentras en el enlace que te enviamos previamente."
                    ),
                    CATEGORIA_CONSULTA_HORARIO: (
                        "¡Hola de nuevo! ⏰ En Parrilladas El Establo atendemos de martes a domingo con los mejores cortes a las brasas. "
                        "Cualquier consulta adicional, no dudes en escribirnos."
                    ),
                    CATEGORIA_CONSULTA_RESERVA: (
                        "¡Hola de nuevo! 🥩 Puedes gestionar los detalles de tu mesa con los datos de contacto que te compartimos "
                        "en el formulario previo. ¡Será un gusto recibirte!"
                    ),
                    CATEGORIA_ELOGIO: (
                        "¡Muchas gracias! 🔥 En Parrilladas El Establo nos apasiona la buena carne a las brasas. "
                        "¡Te esperamos pronto para disfrutar del mejor sabor parrillero! 🥩"
                    ),
                    CATEGORIA_AGRADECIMIENTO: (
                        "¡Muchas gracias por tu comentario! ¡Te esperamos pronto en Parrilladas El Establo! 🥩🔥"
                    ),
                    CATEGORIA_EMOJI_POSITIVO: (
                        "¡Muchas gracias por el apoyo! 🔥🥩 ¡Te esperamos en Parrilladas El Establo!"
                    ),
                    CATEGORIA_SALUDO: (
                        "¡Hola! 🔥 Gracias por comunicarte con Parrilladas El Establo. ¿En qué podemos ayudarte hoy? ¡Te esperamos pronto!"
                    ),
                }
            else:
                templates = {
                    CATEGORIA_CONSULTA_PRECIO: (
                        f"¡Hola! 🔥 Gracias por tu interés en Parrilladas El Establo. Puedes consultar nuestra carta "
                        f"y conocer más sobre nuestros productos. Si deseas recibir atención personalizada, "
                        f"completa nuestro formulario: {form_url}"
                    ),
                    CATEGORIA_INTERES_PRODUCTO: (
                        f"¡Gracias por tu interés! 🥩 Nos encantará ayudarte a conocer los mejores cortes de Parrilladas El Establo. "
                        f"Completa nuestro formulario y podremos brindarte más información: {form_url}"
                    ),
                    CATEGORIA_CONSULTA_PROMOCION: (
                        f"¡Hola! 🔥 Gracias por escribirnos. Puedes consultar las novedades y promociones de Parrilladas El Establo "
                        f"completando el formulario: {form_url}"
                    ),
                    CATEGORIA_CONSULTA_UBICACION: (
                        f"¡Hola! 📍 Te esperamos en el local de Parrilladas El Establo con el auténtico sabor parrillero. "
                        f"Para detalles de ubicación y contacto directo, completa nuestro formulario: {form_url}"
                    ),
                    CATEGORIA_CONSULTA_HORARIO: (
                        f"¡Hola! ⏰ En Parrilladas El Establo atendemos de martes a domingo con los mejores cortes a las brasas. "
                        f"Completa nuestro formulario para recibir atención y novedades: {form_url}"
                    ),
                    CATEGORIA_CONSULTA_RESERVA: (
                        f"¡Hola! 🥩 En Parrilladas El Establo nuestro formulario oficial sirve para solicitar contacto directo y gestionar "
                        f"la disponibilidad de tu mesa: {form_url}"
                    ),
                    CATEGORIA_ELOGIO: (
                        "¡Muchas gracias! 🔥 En Parrilladas El Establo nos apasiona la buena carne a las brasas. "
                        "¡Te esperamos pronto para disfrutar del mejor sabor parrillero! 🥩"
                    ),
                    CATEGORIA_AGRADECIMIENTO: (
                        "¡Muchas gracias por tu comentario! ¡Te esperamos pronto en Parrilladas El Establo! 🥩🔥"
                    ),
                    CATEGORIA_EMOJI_POSITIVO: (
                        "¡Muchas gracias por el apoyo! 🔥🥩 ¡Te esperamos en Parrilladas El Establo!"
                    ),
                    CATEGORIA_SALUDO: (
                        "¡Hola! 🔥 Gracias por comunicarte con Parrilladas El Establo. ¿En qué podemos ayudarte hoy? ¡Te esperamos pronto!"
                    ),
                }
        else:  # INSTAGRAM
            if usuario_ya_recibio_enlace:
                templates = {
                    CATEGORIA_CONSULTA_PRECIO: (
                        "¡Hola nuevamente! 🔥 Recuerda que nuestra carta y formulario de atención están siempre "
                        "disponibles desde el enlace de nuestra biografía. ¡Te esperamos en Parrilladas El Establo! 🥩"
                    ),
                    CATEGORIA_INTERES_PRODUCTO: (
                        "¡Gracias por escribirnos nuevamente! 🥩 Puedes revisar toda la información en el formulario "
                        "enlazado en nuestra biografía. ¡Buen provecho!"
                    ),
                    CATEGORIA_CONSULTA_PROMOCION: (
                        "¡Hola de nuevo! 🔥 Todas nuestras promociones vigentes se encuentran en el enlace de nuestra biografía. "
                        "¡Esperamos tu visita!"
                    ),
                    CATEGORIA_CONSULTA_UBICACION: (
                        "¡Hola nuevamente! 📍 La información de ubicación y contacto directo la encuentras en el enlace de nuestra biografía."
                    ),
                    CATEGORIA_CONSULTA_HORARIO: (
                        "¡Hola de nuevo! ⏰ Atendemos de martes a domingo con las mejores especialidades a las brasas. "
                        "Contáctanos desde el enlace de nuestra biografía."
                    ),
                    CATEGORIA_CONSULTA_RESERVA: (
                        "¡Hola nuevamente! 🥩 Para gestionar la disponibilidad de tu mesa, visita el enlace de nuestra biografía. "
                        "¡Será un gusto atenderte!"
                    ),
                    CATEGORIA_ELOGIO: (
                        "¡Muchas gracias! 🔥 En Parrilladas El Establo siempre listos para ofrecerte la mejor experiencia parrillera. "
                        "¡Te esperamos pronto! 🥩"
                    ),
                    CATEGORIA_AGRADECIMIENTO: (
                        "¡Muchas gracias por tu apoyo! ¡Te esperamos pronto en Parrilladas El Establo! 🥩🔥"
                    ),
                    CATEGORIA_EMOJI_POSITIVO: (
                        "¡Muchas gracias! 🔥🥩 ¡Un fuerte abrazo parrillero!"
                    ),
                    CATEGORIA_SALUDO: (
                        "¡Hola! 🔥 Gracias por comunicarte con Parrilladas El Establo. ¡Un gusto saludarte!"
                    ),
                }
            else:
                templates = {
                    CATEGORIA_CONSULTA_PRECIO: (
                        "¡Hola! 🔥 Gracias por tu interés en Parrilladas El Establo. Puedes consultar nuestra carta "
                        "y acceder al formulario de contacto desde el enlace de nuestra biografía. ¡Te esperamos! 🥩"
                    ),
                    CATEGORIA_INTERES_PRODUCTO: (
                        "¡Gracias por tu interés! 🥩 Nos encantará ayudarte a disfrutar de nuestros mejores cortes "
                        "a la parrilla. Encuentra nuestro formulario de contacto en el enlace de nuestra biografía."
                    ),
                    CATEGORIA_CONSULTA_PROMOCION: (
                        "¡Hola! 🔥 Gracias por escribirnos. Entérate de todas nuestras novedades y promociones "
                        "especiales visitando el enlace de nuestra biografía. ¡Buen provecho!"
                    ),
                    CATEGORIA_CONSULTA_UBICACION: (
                        "¡Hola! 📍 Te esperamos en Parrilladas El Establo con el mejor ambiente parrillero. "
                        "Visita el enlace de nuestra biografía para más detalles y contacto directo."
                    ),
                    CATEGORIA_CONSULTA_HORARIO: (
                        "¡Hola! ⏰ Te esperamos de martes a domingo para disfrutar de nuestras especialidades "
                        "parrilleras. Contáctanos desde el enlace de la biografía."
                    ),
                    CATEGORIA_CONSULTA_RESERVA: (
                        "¡Hola! 🥩 Puedes solicitar contacto para coordinar la disponibilidad de tu mesa a través "
                        "del enlace en nuestra biografía. ¡Será un gusto atenderte!"
                    ),
                    CATEGORIA_ELOGIO: (
                        "¡Muchas gracias! 🔥 En Parrilladas El Establo siempre listos para ofrecerte la mejor experiencia parrillera. "
                        "¡Te esperamos pronto! 🥩"
                    ),
                    CATEGORIA_AGRADECIMIENTO: (
                        "¡Muchas gracias por tu apoyo! ¡Te esperamos pronto en Parrilladas El Establo! 🥩🔥"
                    ),
                    CATEGORIA_EMOJI_POSITIVO: (
                        "¡Muchas gracias! 🔥🥩 ¡Un fuerte abrazo parrillero!"
                    ),
                    CATEGORIA_SALUDO: (
                        "¡Hola! 🔥 Gracias por escribirnos a Parrilladas El Establo. ¡Un gusto saludarte!"
                    ),
                }

        return templates.get(intencion, "")

    def usuario_recibio_enlace_reciente(self, user_id: str | None, hours: int = 24) -> bool:
        """
        Determina si un usuario externo ya recibió previamente una respuesta con enlace
        comercial dentro de la ventana de tiempo especificada (evita repetir enlaces).
        """
        if not user_id or str(user_id).strip() == "":
            return False

        hace = datetime.utcnow() - timedelta(hours=hours)
        form_url = current_app.config.get("AUTO_REPLY_FORM_URL", "https://elestablo.giansmd.dev/registro/")

        try:
            count = (
                RespuestaAutomatica.query.join(InteraccionPublicacion)
                .filter(
                    InteraccionPublicacion.id_usuario_externo == str(user_id).strip(),
                    RespuestaAutomatica.fecha_generacion >= hace,
                    RespuestaAutomatica.estado.in_(["ENVIADA", "APROBADA", "SIMULADA"]),
                    or_(
                        RespuestaAutomatica.texto_respuesta.like(f"%{form_url}%"),
                        RespuestaAutomatica.texto_respuesta.like("%biograf%"),
                        RespuestaAutomatica.texto_respuesta.like("%registro%"),
                    ),
                )
                .count()
            )
            return count > 0
        except Exception as exc:
            logger.warning("Error al consultar historial de enlaces de usuario: %s", str(exc))
            return False

    # =========================================================================
    # Reglas de Elegibilidad y Prevención de Bucles / Spam
    # =========================================================================

    def es_comentario_elegible(
        self,
        comentario: InteraccionPublicacion,
        cooldown_hours: int = 24,
        max_age_hours: int = 72,
    ) -> tuple[bool, str, str]:
        """
        Evalúa si un comentario nuevo de un usuario califica para recibir respuesta automática.
        Retorna: (es_elegible: bool, motivo: str, intencion: str)

        Reglas del Agente BUYER:
        1. Excluir datos DEMO.
        2. Excluir respuestas existentes (evitar responder a comentarios secundarios o sub-hilos si aplica).
        3. Excluir comentarios propios del restaurante y respuestas del agente.
        4. Deduplicación estricta: un mismo comentario (id_interaccion / id_interaccion_externa) nunca recibe dos respuestas.
        5. Límite de antigüedad: evitar respuestas masivas retrospectivas a comentarios antiguos.
        6. Responder tanto a intenciones comerciales como a comentarios positivos o neutrales (elogios, agradecimientos, emojis).
        7. No responder a spam, insultos o información sensible (pasar a revisión / omitir).
        8. Control de ráfagas (rate limiting / anti-flood por usuario) sin bloquear comentarios legítimos subsiguientes.
        """
        # 1. Validación de exclusión de datos DEMO
        if (
            comentario.id_interaccion in (1, 2, 3, 4)
            or (comentario.id_interaccion_externa and comentario.id_interaccion_externa.startswith("DEMO_"))
            or (comentario.publicacion and comentario.publicacion.meta_post_id and comentario.publicacion.meta_post_id.startswith("DEMO_"))
            or (comentario.publicacion and comentario.publicacion.id_publicacion in (1, 2, 3))
        ):
            return False, "Comentario clasificado como registro DEMO/sintético.", CATEGORIA_OTRO

        # 2. Excluir si ya es una respuesta
        if comentario.tipo == "RESPUESTA":
            return False, "La interacción ya es una respuesta a otro comentario.", CATEGORIA_OTRO

        # 3. Excluir comentarios propios del restaurante
        user_id = str(comentario.id_usuario_externo or "").strip()
        user_name = str(comentario.nombre_visible or "").strip().lower()

        known_ids = set(self.KNOWN_RESTAURANT_IDS)
        try:
            page_id = str(current_app.config.get("META_PAGE_ID", "")).strip()
            if page_id:
                known_ids.add(page_id)
            ig_id = str(current_app.config.get("META_IG_ACCOUNT_ID", "")).strip()
            if ig_id:
                known_ids.add(ig_id)
        except Exception:
            pass

        if user_id and user_id in known_ids:
            return False, f"Comentario emitido por la propia cuenta del restaurante (ID {user_id}).", CATEGORIA_OTRO

        if any(known in user_name for known in self.KNOWN_RESTAURANT_NAMES):
            return False, f"Comentario emitido por el restaurante ('{user_name}').", CATEGORIA_OTRO

        # Excluir si el ID externo coincide con una respuesta previamente enviada por el agente
        if comentario.id_interaccion_externa:
            es_respuesta_agente = RespuestaAutomatica.query.filter_by(
                id_respuesta_meta=comentario.id_interaccion_externa
            ).first()
            if es_respuesta_agente:
                return False, "La interacción es una respuesta emitida por el propio agente.", CATEGORIA_OTRO

        # 4. Deduplicación estricta por comentario: UN MISMO COMENTARIO NUNCA RECIBE DOS RESPUESTAS
        respuesta_existente = RespuestaAutomatica.query.filter_by(
            id_interaccion=comentario.id_interaccion
        ).first()
        if respuesta_existente:
            return False, f"El comentario ya cuenta con una respuesta registrada (Estado: {respuesta_existente.estado}).", CATEGORIA_OTRO

        if comentario.id_interaccion_externa:
            resp_por_ext = (
                RespuestaAutomatica.query.join(InteraccionPublicacion)
                .filter(InteraccionPublicacion.id_interaccion_externa == comentario.id_interaccion_externa)
                .first()
            )
            if resp_por_ext:
                return False, f"Ya existe una respuesta para el identificador externo {comentario.id_interaccion_externa}.", CATEGORIA_OTRO

        # 5. Prevención de respuestas retrospectivas masivas a comentarios antiguos
        fecha_inter = getattr(comentario, "fecha_interaccion", None)
        if fecha_inter and max_age_hours > 0:
            limite_antiguedad = datetime.utcnow() - timedelta(hours=max_age_hours)
            if fecha_inter < limite_antiguedad:
                return False, f"Comentario anterior al límite de antigüedad permitido ({max_age_hours}h); omitido para prevenir respuestas retrospectivas masivas.", CATEGORIA_OTRO

        # 6. Clasificar la intención del texto
        intencion = InterestClassifier.clasificar(comentario.texto or "")

        # 7. Filtros de seguridad, moderación y contenido no elegible
        if intencion == CATEGORIA_INAPROPIADO:
            return False, "Comentario clasificado como inapropiado, queja o insulto. Requiere moderación y revisión humana.", intencion

        if intencion == CATEGORIA_DATOS_SENSIBLES:
            return False, "Comentario contiene posible información sensible o confidencial. Requiere revisión humana.", intencion

        if intencion == CATEGORIA_SPAM:
            return False, "Comentario clasificado como spam o enlace externo no autorizado. Omitido.", intencion

        if intencion == CATEGORIA_OTRO:
            return False, "El comentario no contiene un texto o intención interpretable para respuesta automática.", intencion

        # 8. Límite de frecuencia anti-flood por usuario:
        # En lugar de un bloqueo general de 24 horas, permitimos responder a comentarios subsiguientes
        # del mismo usuario pero limitamos ráfagas (bursts) a un máximo razonable (3 respuestas cada 10 min).
        if user_id:
            ventana_minutos = 10
            max_respuestas_ventana = 3
            hace_ventana = datetime.utcnow() - timedelta(minutes=ventana_minutos)

            try:
                dry_run = current_app.config.get("AUTO_REPLY_DRY_RUN", True)
            except Exception:
                dry_run = True

            estados_cuenta = ["ENVIADA", "ENVIANDO", "APROBADA", "PENDIENTE"]
            if dry_run:
                estados_cuenta.append("SIMULADA")

            respuestas_en_ventana = (
                RespuestaAutomatica.query.join(InteraccionPublicacion)
                .filter(
                    InteraccionPublicacion.id_usuario_externo == user_id,
                    RespuestaAutomatica.fecha_generacion >= hace_ventana,
                    RespuestaAutomatica.estado.in_(estados_cuenta),
                )
                .count()
            )
            if respuestas_en_ventana >= max_respuestas_ventana:
                return False, f"Límite de frecuencia temporal por usuario alcanzado ({respuestas_en_ventana} respuestas en {ventana_minutos}m). Enfriamiento anti-flood activo.", intencion

        return True, "Comentario apto para propuesta de respuesta.", intencion

    # =========================================================================
    # Ciclo de Evaluación y Generación de Propuestas
    # =========================================================================

    def procesar_comentarios_nuevos(self, max_comentarios: int | None = None) -> dict[str, Any]:
        """
        Examina comentarios recientes almacenados en la base de datos SQL Server,
        evalúa su elegibilidad y genera propuestas de respuestas automáticas.
        """
        enabled = current_app.config.get("AUTO_REPLY_ENABLED", False)
        dry_run = current_app.config.get("AUTO_REPLY_DRY_RUN", True)
        require_review = current_app.config.get("AUTO_REPLY_REQUIRE_REVIEW", True)
        fb_enabled = current_app.config.get("AUTO_REPLY_FACEBOOK_ENABLED", True)
        ig_enabled = current_app.config.get("AUTO_REPLY_INSTAGRAM_ENABLED", True)
        form_url = current_app.config.get("AUTO_REPLY_FORM_URL", "https://elestablo.giansmd.dev/registro/")
        max_limit = max_comentarios or current_app.config.get("AUTO_REPLY_MAX_PER_CYCLE", 5)
        cooldown_hours = current_app.config.get("AUTO_REPLY_COOLDOWN_HOURS", 24)
        max_age_hours = current_app.config.get("AUTO_REPLY_MAX_COMMENT_AGE_HOURS", 72)

        # 1. Obtener comentarios reales excluyendo DEMO
        com_query = db.session.query(InteraccionPublicacion).join(Publicacion)
        com_query = DataFilterService.apply_real_interaccion_filter(com_query)
        com_query = DataFilterService.apply_real_publicacion_filter(com_query)

        # Filtrar solo comentarios (no respuestas ni reacciones)
        com_query = com_query.filter(InteraccionPublicacion.tipo == "COMENTARIO")

        # Excluir comentarios que ya cuentan con respuesta automática en SQL Server
        com_query = com_query.filter(~InteraccionPublicacion.respuestas_automaticas.any())

        # Ordenar por fecha cronológica ascendente para responder en orden de llegada
        comentarios_candidatos = com_query.order_by(InteraccionPublicacion.fecha_interaccion.asc()).limit(50).all()

        propuestas_generadas: list[dict[str, Any]] = []
        omitidos = 0
        total_evaluados = 0

        for com in comentarios_candidatos:
            if len(propuestas_generadas) >= max_limit:
                break

            total_evaluados += 1
            plat_code = "FACEBOOK" if com.publicacion.id_plataforma == 1 else "INSTAGRAM"

            # Verificar si la plataforma está habilitada para respuestas
            if plat_code == "FACEBOOK" and not fb_enabled:
                omitidos += 1
                continue
            if plat_code == "INSTAGRAM" and not ig_enabled:
                omitidos += 1
                continue

            es_elegible, motivo, intencion = self.es_comentario_elegible(
                com,
                cooldown_hours=cooldown_hours,
                max_age_hours=max_age_hours,
            )

            if not es_elegible:
                omitidos += 1
                continue

            user_id = str(com.id_usuario_externo or "").strip()
            usuario_ya_tiene_enlace = self.usuario_recibio_enlace_reciente(user_id=user_id, hours=cooldown_hours)

            # Generar texto según plantilla y contexto de usuario (sin repetir enlace si ya lo tiene)
            texto = self.get_template(
                plat_code,
                intencion,
                form_url,
                usuario_ya_recibio_enlace=usuario_ya_tiene_enlace,
            )
            if not texto:
                omitidos += 1
                continue

            # Determinar estado inicial
            if dry_run:
                estado_inicial = "SIMULADA"
                tipo_envio = "SIMULADO"
            elif require_review or not enabled:
                estado_inicial = "PENDIENTE"
                tipo_envio = "MANUAL_APROBADO"
            else:
                estado_inicial = "APROBADA"
                tipo_envio = "AUTOMATICO"

            nueva_respuesta = RespuestaAutomatica(
                id_interaccion=com.id_interaccion,
                id_buyer=com.id_buyer,
                id_plataforma=com.publicacion.id_plataforma,
                intencion_detectada=intencion,
                texto_respuesta=texto,
                id_respuesta_meta=None,
                estado=estado_inicial,
                tipo_envio=tipo_envio,
                fecha_generacion=datetime.utcnow(),
                fecha_envio=datetime.utcnow() if dry_run else None,
            )

            try:
                db.session.add(nueva_respuesta)
                db.session.flush()

                # Auditoría de la propuesta generada
                accion_auditoria = AccionAgente(
                    nombre_agente="AutoReplyService",
                    id_buyer=com.id_buyer,
                    accion="PROPONER_RESPUESTA",
                    detalle=f"Propuesta generada para comentario #{com.id_interaccion} ({plat_code}, intencion={intencion}, estado={estado_inicial})",
                    resultado="EXITOSO",
                    fecha_ejecucion=datetime.utcnow(),
                )
                db.session.add(accion_auditoria)
                db.session.commit()

                logger.info(
                    "Propuesta de respuesta automática creada para comentario #%d (%s, %s)",
                    com.id_interaccion,
                    plat_code,
                    estado_inicial,
                )

                # Si el envío automático está activo (no dry_run, enabled y sin revisión previa obligatoria),
                # DESPACHAR INMEDIATAMENTE HACIA META GRAPH API
                if estado_inicial == "APROBADA" and not dry_run and enabled:
                    logger.info("Despachando automáticamente respuesta #%d a Meta...", nueva_respuesta.id_respuesta)
                    envio_res = self.enviar_respuesta(nueva_respuesta.id_respuesta)
                    propuestas_generadas.append(envio_res.get("data", nueva_respuesta.to_dict()))
                else:
                    propuestas_generadas.append(nueva_respuesta.to_dict())

            except Exception as exc:
                db.session.rollback()
                logger.error("Error al persistir propuesta de respuesta automática: %s", str(exc))

        # Despachar respuestas aprobadas pendientes en cola si aplica
        despachadas_cola = 0
        if enabled and not dry_run and not require_review:
            despachadas_cola = self.despachar_respuestas_aprobadas(limite=max_limit)

        return {
            "success": True,
            "total_evaluados": total_evaluados,
            "propuestas_generadas": len(propuestas_generadas),
            "despachadas_cola": despachadas_cola,
            "omitidos": omitidos,
            "items": propuestas_generadas,
        }

    def despachar_respuestas_aprobadas(self, limite: int = 5) -> int:
        """
        Despacha respuestas que ya se encuentren en estado APROBADA hacia Meta Graph API.
        Garantiza que no queden propuestas aprobadas estancadas en cola.
        """
        pendientes = (
            RespuestaAutomatica.query.filter_by(estado="APROBADA")
            .order_by(RespuestaAutomatica.fecha_generacion.asc())
            .limit(limite)
            .all()
        )
        enviadas_count = 0
        for resp in pendientes:
            logger.info("Despachando respuesta en cola #%d hacia Meta...", resp.id_respuesta)
            res = self.enviar_respuesta(resp.id_respuesta)
            if res.get("success"):
                enviadas_count += 1
        return enviadas_count

    # =========================================================================
    # Acciones de Administración: Aprobar, Rechazar, Enviar
    # =========================================================================

    def aprobar_respuesta(self, id_respuesta: int, texto_editado: str | None = None) -> dict[str, Any]:
        """Marca una respuesta como APROBADA (permitiendo opcionalmente editar el texto)."""
        resp = db.session.get(RespuestaAutomatica, id_respuesta)
        if not resp:
            return {"success": False, "error": f"Respuesta #{id_respuesta} no encontrada."}

        if resp.estado in ("ENVIADA", "OMITIDA"):
            return {"success": False, "error": f"No se puede aprobar una respuesta en estado {resp.estado}."}

        if texto_editado and texto_editado.strip():
            resp.texto_respuesta = texto_editado.strip()

        resp.estado = "APROBADA"
        resp.tipo_envio = "MANUAL_APROBADO"

        auditoria = AccionAgente(
            nombre_agente="AutoReplyService",
            id_buyer=resp.id_buyer,
            accion="APROBAR_RESPUESTA",
            detalle=f"Respuesta #{id_respuesta} aprobada manualmente por el administrador.",
            resultado="EXITOSO",
            fecha_ejecucion=datetime.utcnow(),
        )
        db.session.add(auditoria)
        db.session.commit()

        return {"success": True, "data": resp.to_dict()}

    def rechazar_respuesta(self, id_respuesta: int, motivo: str | None = None) -> dict[str, Any]:
        """Marca una respuesta como OMITIDA (rechazada por el administrador)."""
        resp = db.session.get(RespuestaAutomatica, id_respuesta)
        if not resp:
            return {"success": False, "error": f"Respuesta #{id_respuesta} no encontrada."}

        if resp.estado == "ENVIADA":
            return {"success": False, "error": "No se puede rechazar una respuesta que ya fue enviada a Meta."}

        resp.estado = "OMITIDA"
        resp.error_detalle = motivo or "Rechazada manualmente por el administrador."

        auditoria = AccionAgente(
            nombre_agente="AutoReplyService",
            id_buyer=resp.id_buyer,
            accion="RECHAZAR_RESPUESTA",
            detalle=f"Respuesta #{id_respuesta} rechazada. Motivo: {resp.error_detalle}",
            resultado="EXITOSO",
            fecha_ejecucion=datetime.utcnow(),
        )
        db.session.add(auditoria)
        db.session.commit()

        return {"success": True, "data": resp.to_dict()}

    def enviar_respuesta(self, id_respuesta: int) -> dict[str, Any]:
        """
        Despacha la respuesta hacia Meta Graph API o la simula según la configuración.
        NUNCA altera el estado del BUYER a LEAD.
        """
        resp = db.session.get(RespuestaAutomatica, id_respuesta)
        if not resp:
            return {"success": False, "error": f"Respuesta #{id_respuesta} no encontrada."}

        # Protección estricta contra re-envíos e idempotencia
        if resp.estado == "ENVIADA":
            return {
                "success": True,
                "mensaje": "La respuesta ya había sido enviada previamente a Meta.",
                "data": resp.to_dict(),
            }

        dry_run = current_app.config.get("AUTO_REPLY_DRY_RUN", True)
        enabled = current_app.config.get("AUTO_REPLY_ENABLED", False)

        # Si ya fue procesada como SIMULADA y ahora estamos en modo real, bloquear para evitar envíos no deseados
        if resp.estado == "SIMULADA" and not dry_run:
            return {
                "success": False,
                "error": "La respuesta ya fue procesada como SIMULADA (DRY RUN). Por seguridad e idempotencia, no se puede reenviar a Meta sin autorización explícita.",
                "data": resp.to_dict(),
            }

        if resp.estado == "OMITIDA":
            return {
                "success": False,
                "error": "La respuesta se encuentra OMITIDA/RECHAZADA y no puede despacharse.",
                "data": resp.to_dict(),
            }

        if resp.estado == "ENVIANDO":
            return {
                "success": False,
                "error": "La respuesta se encuentra actualmente en proceso de envío.",
                "data": resp.to_dict(),
            }

        comentario = resp.interaccion
        if not comentario or not comentario.id_interaccion_externa:
            resp.estado = "FALLIDA"
            resp.error_detalle = "Interacción no vinculada o carente de ID externo."
            db.session.commit()
            return {"success": False, "error": resp.error_detalle, "data": resp.to_dict()}

        plat_code = "FACEBOOK" if resp.id_plataforma == 1 else "INSTAGRAM"

        # Modo Simulación (Dry Run o Auto-Reply Deshabilitado)
        if dry_run or not enabled:
            resp.estado = "SIMULADA"
            resp.tipo_envio = "SIMULADO"
            resp.fecha_envio = datetime.utcnow()
            resp.id_respuesta_meta = f"SIMULATED_REPLY_{resp.id_respuesta}_{int(datetime.utcnow().timestamp())}"
            resp.error_detalle = None

            auditoria = AccionAgente(
                nombre_agente="AutoReplyService",
                id_buyer=resp.id_buyer,
                accion="SIMULAR_RESPUESTA",
                detalle=f"Respuesta #{id_respuesta} simulada exitosamente ({plat_code}, DRY_RUN={dry_run}).",
                resultado="EXITOSO",
                fecha_ejecucion=datetime.utcnow(),
            )
            db.session.add(auditoria)
            db.session.commit()

            logger.info("Respuesta #%d simulada exitosamente (DRY RUN).", id_respuesta)
            return {
                "success": True,
                "simulada": True,
                "mensaje": "Respuesta procesada en modo SIMULACIÓN (DRY RUN). Ningún mensaje fue publicado en redes externas.",
                "data": resp.to_dict(),
            }

        # Modo Envío Real a Meta Graph API
        client = self._get_meta_client()
        resp.estado = "ENVIANDO"
        db.session.commit()

        try:
            if plat_code == "FACEBOOK":
                res = client.reply_facebook_comment(
                    comment_id=comentario.id_interaccion_externa,
                    message=resp.texto_respuesta,
                )
            else:
                res = client.reply_instagram_comment(
                    comment_id=comentario.id_interaccion_externa,
                    message=resp.texto_respuesta,
                )

            # Requisito 10: Validar estrictamente la confirmación de Meta
            meta_id = res.get("id") if isinstance(res, dict) else None
            if not meta_id or not str(meta_id).strip():
                raise MetaClientError(f"Meta Graph API no devolvió un identificador de confirmación válido. Respuesta recibida: {res}")

            resp.id_respuesta_meta = str(meta_id).strip()
            resp.estado = "ENVIADA"
            resp.fecha_envio = datetime.utcnow()
            resp.error_detalle = None

            auditoria = AccionAgente(
                nombre_agente="AutoReplyService",
                id_buyer=resp.id_buyer,
                accion="ENVIAR_RESPUESTA",
                detalle=f"Respuesta #{id_respuesta} enviada exitosamente a Meta ({plat_code}, Meta ID: {meta_id}).",
                resultado="EXITOSO",
                fecha_ejecucion=datetime.utcnow(),
            )
            db.session.add(auditoria)
            db.session.commit()

            logger.info("Respuesta #%d enviada a Meta con éxito (Meta ID: %s).", id_respuesta, meta_id)
            return {
                "success": True,
                "simulada": False,
                "data": resp.to_dict(),
            }

        except Exception as exc:
            db.session.rollback()
            error_msg = str(exc)
            resp_recargada = db.session.get(RespuestaAutomatica, id_respuesta)
            if resp_recargada:
                resp_recargada.estado = "FALLIDA"
                resp_recargada.error_detalle = error_msg[:1000]

                auditoria = AccionAgente(
                    nombre_agente="AutoReplyService",
                    id_buyer=resp_recargada.id_buyer,
                    accion="ENVIAR_RESPUESTA",
                    detalle=f"Fallo al enviar respuesta #{id_respuesta} ({plat_code}): {error_msg[:300]}",
                    resultado="FALLIDO",
                    fecha_ejecucion=datetime.utcnow(),
                )
                db.session.add(auditoria)
                db.session.commit()
                resp = resp_recargada

            logger.error("Error al despachar respuesta #%d a Meta: %s", id_respuesta, error_msg)
            return {
                "success": False,
                "error": error_msg,
                "data": resp.to_dict() if resp else None,
            }

    # =========================================================================
    # Métricas y Resumen de Estado
    # =========================================================================

    def get_status(self) -> dict[str, Any]:
        """Retorna la configuración activa y el conteo consolidado de respuestas."""
        total_respuestas = RespuestaAutomatica.query.count()
        pendientes = RespuestaAutomatica.query.filter_by(estado="PENDIENTE").count()
        aprobadas = RespuestaAutomatica.query.filter_by(estado="APROBADA").count()
        simuladas = RespuestaAutomatica.query.filter_by(estado="SIMULADA").count()
        enviadas = RespuestaAutomatica.query.filter_by(estado="ENVIADA").count()
        fallidas = RespuestaAutomatica.query.filter_by(estado="FALLIDA").count()
        omitidas = RespuestaAutomatica.query.filter_by(estado="OMITIDA").count()

        # Comentarios elegibles pendientes en la base de datos
        com_query = db.session.query(InteraccionPublicacion).join(Publicacion)
        com_query = DataFilterService.apply_real_interaccion_filter(com_query)
        com_query = DataFilterService.apply_real_publicacion_filter(com_query)
        total_comentarios_reales = com_query.filter(InteraccionPublicacion.tipo == "COMENTARIO").count()

        return {
            "config": {
                "enabled": current_app.config.get("AUTO_REPLY_ENABLED", False),
                "dry_run": current_app.config.get("AUTO_REPLY_DRY_RUN", True),
                "require_review": current_app.config.get("AUTO_REPLY_REQUIRE_REVIEW", True),
                "facebook_enabled": current_app.config.get("AUTO_REPLY_FACEBOOK_ENABLED", True),
                "instagram_enabled": current_app.config.get("AUTO_REPLY_INSTAGRAM_ENABLED", True),
                "form_url": current_app.config.get("AUTO_REPLY_FORM_URL", "https://elestablo.giansmd.dev/registro/"),
                "landing_url": current_app.config.get("AUTO_REPLY_LANDING_URL", "https://elestablo.giansmd.dev/"),
                "max_per_cycle": current_app.config.get("AUTO_REPLY_MAX_PER_CYCLE", 5),
                "cooldown_hours": current_app.config.get("AUTO_REPLY_COOLDOWN_HOURS", 24),
            },
            "metricas": {
                "total_comentarios_reales": total_comentarios_reales,
                "total_respuestas": total_respuestas,
                "pendientes": pendientes,
                "aprobadas": aprobadas,
                "simuladas": simuladas,
                "enviadas": enviadas,
                "fallidas": fallidas,
                "omitidas": omitidas,
            },
        }

    def activar_envio_automatico(self) -> dict[str, Any]:
        """Activa inmediatamente el envío automático sin aprobación manual previa."""
        current_app.config["AUTO_REPLY_ENABLED"] = True
        current_app.config["AUTO_REPLY_DRY_RUN"] = False
        current_app.config["AUTO_REPLY_REQUIRE_REVIEW"] = False
        logger.info("Envío automático de respuestas activado (AUTO_REPLY_ENABLED=True, DRY_RUN=False, REQUIRE_REVIEW=False).")
        return self.get_status()

    def desactivar_envio_automatico(self, motivo: str = "Parada de emergencia ejecutada por administrador") -> dict[str, Any]:
        """
        Desactiva inmediatamente el envío automático a Meta Graph API (Emergency Kill Switch).
        Las respuestas generadas quedarán en modo revisión (PENDIENTE) sin publicarse externamente.
        """
        current_app.config["AUTO_REPLY_ENABLED"] = False
        logger.warning("PARADA DE EMERGENCIA: Envío automático desactivado. Motivo: %s", motivo)
        return self.get_status()

    def list_respuestas(
        self,
        estado: str | None = None,
        plataforma: str | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> dict[str, Any]:
        """Lista el historial de respuestas con filtros opcionales."""
        query = RespuestaAutomatica.query

        if estado and estado.strip():
            query = query.filter(RespuestaAutomatica.estado == estado.strip().upper())

        if plataforma and plataforma.strip():
            plat_clean = plataforma.strip().lower()
            if plat_clean == "facebook":
                query = query.filter(RespuestaAutomatica.id_plataforma == 1)
            elif plat_clean == "instagram":
                query = query.filter(RespuestaAutomatica.id_plataforma == 2)

        total = query.count()
        items = (
            query.order_by(desc(RespuestaAutomatica.fecha_generacion))
            .offset(offset)
            .limit(limit)
            .all()
        )

        return {
            "total": total,
            "limit": limit,
            "offset": offset,
            "items": [r.to_dict() for r in items],
        }

    # =========================================================================
    # Trazabilidad Detallada de Comentarios y Respuestas
    # =========================================================================

    def obtener_trazabilidad_comentarios(
        self,
        limite: int = 50,
        offset: int = 0,
        filtro_estado: str | None = None,
        plataforma: str | None = None,
    ) -> dict[str, Any]:
        """
        Retorna la trazabilidad completa de los comentarios analizados por el agente.
        Permite auditar por qué cada comentario fue respondido, simulado, omitido,
        bloqueado por cooldown o quedó pendiente.
        """
        cooldown_hours = current_app.config.get("AUTO_REPLY_COOLDOWN_HOURS", 24)
        fb_enabled = current_app.config.get("AUTO_REPLY_FACEBOOK_ENABLED", True)
        ig_enabled = current_app.config.get("AUTO_REPLY_INSTAGRAM_ENABLED", True)

        # Consultar comentarios reales ordenados por fecha descendente
        com_query = db.session.query(InteraccionPublicacion).join(Publicacion)
        com_query = DataFilterService.apply_real_interaccion_filter(com_query)
        com_query = DataFilterService.apply_real_publicacion_filter(com_query)
        com_query = com_query.filter(InteraccionPublicacion.tipo == "COMENTARIO")

        if plataforma and plataforma.strip():
            plat_clean = plataforma.strip().lower()
            if plat_clean == "facebook":
                com_query = com_query.filter(Publicacion.id_plataforma == 1)
            elif plat_clean == "instagram":
                com_query = com_query.filter(Publicacion.id_plataforma == 2)

        todos_los_comentarios = com_query.order_by(desc(InteraccionPublicacion.fecha_interaccion)).all()

        items: list[dict[str, Any]] = []
        conteo_resumen = {
            "total_evaluados": len(todos_los_comentarios),
            "respondidos_meta": 0,
            "simulados": 0,
            "pendientes_revision": 0,
            "aprobados_cola": 0,
            "bloqueados_cooldown": 0,
            "omitidos_sin_intencion": 0,
            "omitidos_propios": 0,
            "fallidos": 0,
            "descartados_manual": 0,
            "pendientes_evaluacion": 0,
        }

        # Cargar respuestas existentes indexadas por id_interaccion
        respuestas_map = {
            r.id_interaccion: r
            for r in RespuestaAutomatica.query.all()
        }

        for com in todos_los_comentarios:
            plat_code = "FACEBOOK" if com.publicacion.id_plataforma == 1 else "INSTAGRAM"
            resp = respuestas_map.get(com.id_interaccion)

            if resp:
                estado_resp = resp.estado
                if estado_resp == "ENVIADA":
                    estado_trazabilidad = "RESPONDIDO_META"
                    motivo = f"Respuesta publicada exitosamente en Meta Graph API (ID Meta: {resp.id_respuesta_meta})."
                    conteo_resumen["respondidos_meta"] += 1
                elif estado_resp == "SIMULADA":
                    estado_trazabilidad = "SIMULADO_DRY_RUN"
                    motivo = "Evaluada y simulada en modo de prueba (DRY RUN). Ningún mensaje publicado en redes."
                    conteo_resumen["simulados"] += 1
                elif estado_resp == "PENDIENTE":
                    estado_trazabilidad = "PENDIENTE_REVISION"
                    motivo = "Propuesta comercial generada, esperando aprobación manual de un administrador."
                    conteo_resumen["pendientes_revision"] += 1
                elif estado_resp == "APROBADA":
                    estado_trazabilidad = "APROBADO_EN_COLA"
                    motivo = "Respuesta aprobada, lista para ser enviada a Meta Graph API."
                    conteo_resumen["aprobados_cola"] += 1
                elif estado_resp == "FALLIDA":
                    estado_trazabilidad = "FALLIDO_META"
                    motivo = f"Error al despachar a Meta: {resp.error_detalle or 'Error no especificado'}"
                    conteo_resumen["fallidos"] += 1
                elif estado_resp == "OMITIDA":
                    estado_trazabilidad = "DESCARTADO_MANUAL"
                    motivo = f"Propuesta rechazada manualmente: {resp.error_detalle or 'Sin motivo'}"
                    conteo_resumen["descartados_manual"] += 1
                else:
                    estado_trazabilidad = estado_resp
                    motivo = f"Estado actual de la respuesta: {estado_resp}"

                info_item = {
                    "id_interaccion": com.id_interaccion,
                    "id_interaccion_externa": com.id_interaccion_externa,
                    "id_publicacion": com.id_publicacion,
                    "plataforma": plat_code,
                    "fecha_interaccion": com.fecha_interaccion.isoformat() if com.fecha_interaccion else None,
                    "usuario_nombre": com.nombre_visible or "Anónimo",
                    "usuario_id": com.id_usuario_externo,
                    "texto_comentario": com.texto,
                    "intencion_detectada": resp.intencion_detectada or com.categoria_intencion or CATEGORIA_OTRO,
                    "estado_trazabilidad": estado_trazabilidad,
                    "motivo_trazabilidad": motivo,
                    "tiene_respuesta": True,
                    "id_respuesta": resp.id_respuesta,
                    "texto_respuesta": resp.texto_respuesta,
                    "id_respuesta_meta": resp.id_respuesta_meta,
                    "fecha_envio": resp.fecha_envio.isoformat() if resp.fecha_envio else None,
                    "error_detalle": resp.error_detalle,
                }
            else:
                # No tiene respuesta automática en BD: evaluar por qué no la tiene
                es_elegible, motivo_eval, intencion = self.es_comentario_elegible(com, cooldown_hours=cooldown_hours)

                if not es_elegible:
                    motivo_lower = motivo_eval.lower()
                    if "enfriamiento" in motivo_lower or "cooldown" in motivo_lower or "frecuencia" in motivo_lower:
                        estado_trazabilidad = "BLOQUEADO_COOLDOWN"
                        conteo_resumen["bloqueados_cooldown"] += 1
                    elif "propia cuenta" in motivo_lower or "por el restaurante" in motivo_lower or "agente" in motivo_lower:
                        estado_trazabilidad = "OMITIDO_PROPIO"
                        conteo_resumen["omitidos_propios"] += 1
                    elif "inapropiado" in motivo_lower or "insulto" in motivo_lower or "moderación" in motivo_lower:
                        estado_trazabilidad = "OMITIDO_INAPROPIADO"
                        conteo_resumen["descartados_manual"] += 1
                    elif "spam" in motivo_lower:
                        estado_trazabilidad = "OMITIDO_SPAM"
                        conteo_resumen["omitidos_sin_intencion"] += 1
                    elif "sensible" in motivo_lower:
                        estado_trazabilidad = "OMITIDO_DATOS_SENSIBLES"
                        conteo_resumen["descartados_manual"] += 1
                    elif "antigüedad" in motivo_lower or "retrospectivas" in motivo_lower:
                        estado_trazabilidad = "OMITIDO_ANTIGUEDAD"
                        conteo_resumen["omitidos_sin_intencion"] += 1
                    elif "no contiene" in motivo_lower or intencion == CATEGORIA_OTRO:
                        estado_trazabilidad = "OMITIDO_SIN_INTENCION_COMERCIAL"
                        conteo_resumen["omitidos_sin_intencion"] += 1
                    else:
                        estado_trazabilidad = "OMITIDO_REGLA_NEGOCIO"
                    motivo = motivo_eval
                else:
                    # Es elegible pero aún no tiene propuesta registrada
                    if plat_code == "FACEBOOK" and not fb_enabled:
                        estado_trazabilidad = "OMITIDO_PLATAFORMA_DESHABILITADA"
                        motivo = "Facebook auto-reply se encuentra deshabilitado en configuración."
                    elif plat_code == "INSTAGRAM" and not ig_enabled:
                        estado_trazabilidad = "OMITIDO_PLATAFORMA_DESHABILITADA"
                        motivo = "Instagram auto-reply se encuentra deshabilitado en configuración."
                    else:
                        estado_trazabilidad = "PENDIENTE_EVALUACION"
                        motivo = f"Comentario con intención '{intencion}' elegible. En cola para el siguiente ciclo de sincronización."
                        conteo_resumen["pendientes_evaluacion"] += 1

                info_item = {
                    "id_interaccion": com.id_interaccion,
                    "id_interaccion_externa": com.id_interaccion_externa,
                    "id_publicacion": com.id_publicacion,
                    "plataforma": plat_code,
                    "fecha_interaccion": com.fecha_interaccion.isoformat() if com.fecha_interaccion else None,
                    "usuario_nombre": com.nombre_visible or "Anónimo",
                    "usuario_id": com.id_usuario_externo,
                    "texto_comentario": com.texto,
                    "intencion_detectada": intencion or com.categoria_intencion or CATEGORIA_OTRO,
                    "estado_trazabilidad": estado_trazabilidad,
                    "motivo_trazabilidad": motivo,
                    "tiene_respuesta": False,
                    "id_respuesta": None,
                    "texto_respuesta": None,
                    "id_respuesta_meta": None,
                    "fecha_envio": None,
                    "error_detalle": None,
                }

            # Filtro opcional por estado de trazabilidad
            if filtro_estado and filtro_estado.strip():
                if info_item["estado_trazabilidad"] != filtro_estado.strip().upper():
                    continue

            items.append(info_item)

        total_filtrado = len(items)
        items_paginados = items[offset : offset + limite]

        return {
            "total": total_filtrado,
            "limit": limite,
            "offset": offset,
            "resumen": conteo_resumen,
            "items": items_paginados,
        }
