"""
Repositorio para las entidades y tablas vinculadas a la captación de Instagram:
- dbo.plataforma
- dbo.publicacion
- dbo.interaccion_publicacion
- dbo.buyer
- dbo.metrica_publicacion_diaria
- dbo.evento_integracion
- dbo.accion_agente
"""
from __future__ import annotations

import logging
from datetime import datetime, date
from typing import Any
from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import EventoIntegracion, AccionAgente
from app.services.data_filter_service import DataFilterService, DEMO_PUBLICACION_IDS, DEMO_INTERACCION_IDS

logger = logging.getLogger("instagram_repository")


class InstagramRepository:
    """
    Operaciones seguras e idempotentes de base de datos para la sincronización de Instagram.
    Utiliza exactamente las mismas tablas existentes del modelo 'buyer'.
    """

    @staticmethod
    def get_instagram_platform() -> Plataforma | None:
        """Obtiene el registro de catálogo de la plataforma INSTAGRAM."""
        return db.session.query(Plataforma).filter(Plataforma.codigo == "INSTAGRAM").first()

    @staticmethod
    def update_instagram_platform_meta_id(
        meta_account_id: str,
        nombre_pagina: str | None = None,
        url_pagina: str | None = None,
    ) -> Plataforma | None:
        """Actualiza el meta_account_id y datos oficiales de la plataforma Instagram en dbo.plataforma."""
        ig_plat = InstagramRepository.get_instagram_platform()
        if ig_plat:
            changed = False
            if meta_account_id and ig_plat.meta_account_id != meta_account_id:
                ig_plat.meta_account_id = meta_account_id[:100]
                changed = True
            if nombre_pagina and ig_plat.nombre_pagina != nombre_pagina:
                ig_plat.nombre_pagina = nombre_pagina[:150]
                changed = True
            if url_pagina and ig_plat.url_pagina != url_pagina:
                ig_plat.url_pagina = url_pagina[:500]
                changed = True
            if changed:
                db.session.flush()
        return ig_plat

    @staticmethod
    def upsert_publicacion(
        id_plataforma: int,
        meta_post_id: str,
        texto: str | None,
        url_publicacion: str | None,
        url_formulario: str | None,
        fecha_publicacion: datetime,
        id_campana: int | None = None,
    ) -> tuple[Publicacion, bool]:
        """
        UPSERT seguro e idempotente de dbo.publicacion para Instagram.
        Restricción UNIQUE: (id_plataforma, meta_post_id).
        Retorna (publicacion, creada: bool).
        """
        post = (
            db.session.query(Publicacion)
            .filter(
                Publicacion.id_plataforma == id_plataforma,
                Publicacion.meta_post_id == meta_post_id,
            )
            .first()
        )

        safe_texto = texto[:2000] if texto else None
        safe_url_pub = url_publicacion[:600] if url_publicacion else None
        safe_url_form = url_formulario[:600] if url_formulario else None

        if post:
            changed = False
            if post.texto != safe_texto:
                post.texto = safe_texto
                changed = True
            if safe_url_pub and post.url_publicacion != safe_url_pub:
                post.url_publicacion = safe_url_pub
                changed = True
            if safe_url_form and post.url_formulario != safe_url_form:
                post.url_formulario = safe_url_form
                changed = True
            if post.estado != "PUBLICADA":
                post.estado = "PUBLICADA"
                changed = True
            if id_campana is not None and post.id_campana is None:
                post.id_campana = id_campana
                changed = True

            db.session.flush()
            return post, False

        new_post = Publicacion(
            id_plataforma=id_plataforma,
            id_campana=id_campana,
            meta_post_id=meta_post_id,
            texto=safe_texto,
            url_publicacion=safe_url_pub,
            url_formulario=safe_url_form,
            fecha_publicacion=fecha_publicacion,
            estado="PUBLICADA",
        )
        db.session.add(new_post)
        db.session.flush()
        return new_post, True

    @staticmethod
    def find_or_create_buyer(
        id_plataforma_origen: int,
        referencia_externa: str,
        id_publicacion_origen: int | None = None,
        fecha_primer_contacto: datetime | None = None,
    ) -> tuple[Buyer | None, bool]:
        """
        Localiza o crea el registro en dbo.buyer para un usuario de Instagram con ID externo estable.
        - id_persona: NULL (NUNCA crear una persona ficticia).
        - Reutiliza el BUYER si el mismo usuario ya existe en la plataforma.
        """
        clean_ref = (referencia_externa or "").strip()
        if not clean_ref:
            return None, False

        safe_ref = clean_ref[:150]

        existing = (
            db.session.query(Buyer)
            .filter(
                Buyer.id_plataforma_origen == id_plataforma_origen,
                Buyer.referencia_externa == safe_ref,
            )
            .first()
        )

        if existing:
            return existing, False

        contact_date = fecha_primer_contacto or datetime.utcnow()
        new_buyer = Buyer(
            id_persona=None,
            id_plataforma_origen=id_plataforma_origen,
            id_publicacion_origen=id_publicacion_origen,
            id_anuncio_origen=None,
            referencia_externa=safe_ref,
            fecha_primer_contacto=contact_date,
            estado="BUYER",
            fecha_conversion=None,
        )
        db.session.add(new_buyer)
        db.session.flush()
        return new_buyer, True

    @staticmethod
    def upsert_interaccion(
        id_publicacion: int,
        id_interaccion_externa: str,
        tipo: str,
        id_usuario_externo: str | None,
        nombre_visible: str | None,
        texto: str | None,
        fecha_interaccion: datetime,
        id_buyer: int | None = None,
    ) -> tuple[InteraccionPublicacion, bool]:
        """
        UPSERT seguro e idempotente en dbo.interaccion_publicacion para Instagram.
        Restricción UNIQUE: (id_publicacion, id_interaccion_externa).
        """
        safe_ext_id = id_interaccion_externa[:150]
        safe_tipo = tipo.upper() if tipo.upper() in ("COMENTARIO", "RESPUESTA", "REACCION") else "COMENTARIO"
        safe_user_id = id_usuario_externo[:150] if id_usuario_externo else None
        safe_nombre = nombre_visible[:150] if nombre_visible else None
        safe_texto = texto[:2000] if texto else None

        interaccion = (
            db.session.query(InteraccionPublicacion)
            .filter(
                InteraccionPublicacion.id_publicacion == id_publicacion,
                InteraccionPublicacion.id_interaccion_externa == safe_ext_id,
            )
            .first()
        )

        if interaccion:
            changed = False
            if interaccion.texto != safe_texto:
                interaccion.texto = safe_texto
                changed = True
            if safe_nombre and interaccion.nombre_visible != safe_nombre:
                interaccion.nombre_visible = safe_nombre
                changed = True
            if id_buyer is not None and interaccion.id_buyer != id_buyer:
                interaccion.id_buyer = id_buyer
                changed = True
            db.session.flush()
            return interaccion, False

        new_interaccion = InteraccionPublicacion(
            id_publicacion=id_publicacion,
            id_buyer=id_buyer,
            id_interaccion_externa=safe_ext_id,
            tipo=safe_tipo,
            id_usuario_externo=safe_user_id,
            nombre_visible=safe_nombre,
            texto=safe_texto,
            fecha_interaccion=fecha_interaccion,
            fecha_ingesta=datetime.utcnow(),
        )
        db.session.add(new_interaccion)
        db.session.flush()
        return new_interaccion, True

    @staticmethod
    def upsert_metrica_diaria(
        id_publicacion: int,
        fecha_corte: date,
        total_reacciones: int | None = None,
        total_comentarios: int | None = None,
        total_compartidos: int | None = None,
        alcance: int | None = None,
        impresiones: int | None = None,
    ) -> tuple[MetricaPublicacionDiaria, bool]:
        """
        UPSERT seguro e idempotente en dbo.metrica_publicacion_diaria para Instagram.
        Restricción UNIQUE: (id_publicacion, fecha_corte).
        """
        metrica = (
            db.session.query(MetricaPublicacionDiaria)
            .filter(
                MetricaPublicacionDiaria.id_publicacion == id_publicacion,
                MetricaPublicacionDiaria.fecha_corte == fecha_corte,
            )
            .first()
        )

        if metrica:
            if total_reacciones is not None:
                metrica.total_reacciones = total_reacciones
            if total_comentarios is not None:
                metrica.total_comentarios = total_comentarios
            if total_compartidos is not None:
                metrica.total_compartidos = total_compartidos
            if alcance is not None:
                metrica.alcance = alcance
            if impresiones is not None:
                metrica.impresiones = impresiones
            metrica.fecha_obtencion = datetime.utcnow()
            db.session.flush()
            return metrica, False

        new_metrica = MetricaPublicacionDiaria(
            id_publicacion=id_publicacion,
            fecha_corte=fecha_corte,
            total_reacciones=total_reacciones,
            total_comentarios=total_comentarios,
            total_compartidos=total_compartidos,
            alcance=alcance,
            impresiones=impresiones,
            fecha_obtencion=datetime.utcnow(),
        )
        db.session.add(new_metrica)
        db.session.flush()
        return new_metrica, True

    @staticmethod
    def record_evento_integracion(
        id_evento_externo: str,
        tipo: str,
        estado: str = "PROCESADO",
        error_resumen: str | None = None,
    ) -> EventoIntegracion:
        """Registra el evento externo en dbo.evento_integracion con proveedor='META'."""
        safe_id = id_evento_externo[:200]
        safe_tipo = tipo[:50]
        safe_estado = estado.upper() if estado.upper() in ("RECIBIDO", "PROCESADO", "ERROR") else "PROCESADO"
        safe_error = error_resumen[:300] if error_resumen else None

        evento = (
            db.session.query(EventoIntegracion)
            .filter(
                EventoIntegracion.proveedor == "META",
                EventoIntegracion.id_evento_externo == safe_id,
            )
            .first()
        )

        now = datetime.utcnow()
        if evento:
            evento.tipo = safe_tipo
            evento.procesado_en = now
            evento.estado = safe_estado
            evento.error_resumen = safe_error
            db.session.flush()
            return evento

        new_evento = EventoIntegracion(
            proveedor="META",
            id_evento_externo=safe_id,
            tipo=safe_tipo,
            recibido_en=now,
            procesado_en=now,
            estado=safe_estado,
            error_resumen=safe_error,
        )
        db.session.add(new_evento)
        db.session.flush()
        return new_evento

    @staticmethod
    def record_accion_agente(
        accion: str,
        detalle: str | None,
        resultado: str,
        nombre_agente: str = "AgenteInstagram",
        id_buyer: int | None = None,
    ) -> AccionAgente:
        """Registra la ejecución en dbo.accion_agente con nombre_agente='AgenteInstagram'."""
        safe_accion = accion[:50]
        safe_resultado = resultado.upper() if resultado.upper() in ("EXITOSO", "FALLIDO", "PENDIENTE") else "EXITOSO"
        safe_detalle = detalle[:500] if detalle else None

        accion_record = AccionAgente(
            nombre_agente=nombre_agente[:60],
            id_buyer=id_buyer,
            id_sesion_whatsapp=None,
            accion=safe_accion,
            detalle=safe_detalle,
            resultado=safe_resultado,
            fecha_ejecucion=datetime.utcnow(),
        )
        db.session.add(accion_record)
        db.session.flush()
        return accion_record

    # =========================================================================
    # Consultas para Endpoints REST
    # =========================================================================

    @staticmethod
    def get_publicaciones(
        limit: int = 50,
        offset: int = 0,
        include_demo: bool = False,
    ) -> tuple[list[Publicacion], int]:
        """Lista las publicaciones de Instagram registradas en la base de datos."""
        ig_plat = InstagramRepository.get_instagram_platform()
        if not ig_plat:
            return [], 0

        query = (
            db.session.query(Publicacion)
            .filter(Publicacion.id_plataforma == ig_plat.id_plataforma)
        )
        if not include_demo:
            query = DataFilterService.apply_real_publicacion_filter(query)

        query = query.order_by(Publicacion.fecha_publicacion.desc())
        total = query.count()
        items = query.offset(offset).limit(limit).all()
        return items, total

    @staticmethod
    def get_publicacion_by_id(id_publicacion: int) -> Publicacion | None:
        """Obtiene una publicación de Instagram por su ID primario."""
        ig_plat = InstagramRepository.get_instagram_platform()
        if not ig_plat:
            return None
        return (
            db.session.query(Publicacion)
            .filter(
                Publicacion.id_publicacion == id_publicacion,
                Publicacion.id_plataforma == ig_plat.id_plataforma,
            )
            .first()
        )

    @staticmethod
    def get_comentarios_by_publicacion(
        id_publicacion: int,
        limit: int = 100,
        offset: int = 0,
        include_demo: bool = False,
    ) -> tuple[list[InteraccionPublicacion], int]:
        """Obtiene las interacciones de una publicación de Instagram."""
        query = (
            db.session.query(InteraccionPublicacion)
            .filter(InteraccionPublicacion.id_publicacion == id_publicacion)
        )
        if not include_demo:
            query = DataFilterService.apply_real_interaccion_filter(query)

        query = query.order_by(InteraccionPublicacion.fecha_interaccion.asc())
        total = query.count()
        items = query.offset(offset).limit(limit).all()
        return items, total

    @staticmethod
    def get_metricas(
        id_publicacion: int | None = None,
        limit: int = 50,
        offset: int = 0,
        include_demo: bool = False,
    ) -> tuple[list[MetricaPublicacionDiaria], int]:
        """Obtiene las métricas diarias registradas para publicaciones de Instagram."""
        query = (
            db.session.query(MetricaPublicacionDiaria)
            .join(Publicacion, MetricaPublicacionDiaria.id_publicacion == Publicacion.id_publicacion)
            .join(Plataforma, Publicacion.id_plataforma == Plataforma.id_plataforma)
            .filter(Plataforma.codigo == "INSTAGRAM")
        )
        if not include_demo:
            query = query.filter(
                ~Publicacion.meta_post_id.like("DEMO_%"),
                ~Publicacion.id_publicacion.in_(DEMO_PUBLICACION_IDS),
            )

        if id_publicacion is not None:
            query = query.filter(MetricaPublicacionDiaria.id_publicacion == id_publicacion)

        query = query.order_by(MetricaPublicacionDiaria.fecha_corte.desc())
        total = query.count()
        items = query.offset(offset).limit(limit).all()
        return items, total
