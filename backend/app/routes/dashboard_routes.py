"""
Rutas del Dashboard Web y Endpoints Analíticos:
- GET /dashboard               -> Interfaz web local interactiva (Jinja2 + Bootstrap)
- GET /api/dashboard/resumen   -> Resumen consolidado exclusivamente con datos REALES
- GET /api/dashboard/comentarios -> Tabla de comentarios reales con clasificación de intención
- GET /api/dashboard/buyers    -> Tabla de BUYERS reales comprobados con procedencia e interacciones
"""
from __future__ import annotations

import logging
from datetime import datetime
from typing import Any
from flask import Blueprint, jsonify, render_template, request
from sqlalchemy import func, desc, and_

from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import AccionAgente
from app.services.interest_classifier import InterestClassifier
from app.services.sync_scheduler import SyncSchedulerService
from app.services.data_filter_service import DataFilterService
from app.services.buyer_service import mask_external_ref
from app.services.kpi_service import KpiService
from app.models.web import VisitaWeb
from app.models.conversion import FormularioCaptacion

logger = logging.getLogger("dashboard_routes")
dashboard_bp = Blueprint("dashboard", __name__)


@dashboard_bp.route("/dashboard", methods=["GET"])
@dashboard_bp.route("/", methods=["GET"])
def index():
    """
    Renderiza la vista principal del Dashboard Web Local.
    """
    return render_template("dashboard/index.html")


@dashboard_bp.route("/api/dashboard/resumen", methods=["GET"])
def get_dashboard_resumen():
    """
    Retorna métricas consolidadas utilizando EXCLUSIVAMENTE datos reales confirmados de Meta Graph API:
    - Publicaciones reales de Facebook e Instagram
    - Comentarios reales capturados vs reportados por Meta
    - Reacciones reales actuales de Facebook y likes de Instagram (último corte por publicación)
    - BUYERS reales identificados desde interacciones reales
    - Última sincronización y estado de agentes
    """
    # 1. Publicaciones Reales
    pub_query = db.session.query(Publicacion)
    pub_query = DataFilterService.apply_real_publicacion_filter(pub_query)
    posts_reales = pub_query.all()

    fb_posts_reales = sum(1 for p in posts_reales if p.id_plataforma == 1)
    ig_posts_reales = sum(1 for p in posts_reales if p.id_plataforma == 2)
    total_posts_reales = fb_posts_reales + ig_posts_reales

    # 2. Comentarios Reales Capturados
    com_query = db.session.query(InteraccionPublicacion).join(Publicacion)
    com_query = DataFilterService.apply_real_interaccion_filter(com_query)
    com_query = DataFilterService.apply_real_publicacion_filter(com_query)
    comentarios_reales = com_query.all()

    fb_comentarios_capturados = sum(
        1 for c in comentarios_reales if c.publicacion and c.publicacion.id_plataforma == 1
    )
    ig_comentarios_capturados = sum(
        1 for c in comentarios_reales if c.publicacion and c.publicacion.id_plataforma == 2
    )
    total_comentarios_reales = len(comentarios_reales)

    # 3. Métricas agregadas de Meta (utilizando el último corte válido por publicación real)
    subq_max_corte = (
        db.session.query(
            MetricaPublicacionDiaria.id_publicacion,
            func.max(MetricaPublicacionDiaria.fecha_corte).label("max_fecha"),
        )
        .group_by(MetricaPublicacionDiaria.id_publicacion)
        .subquery()
    )

    metricas_query = (
        db.session.query(MetricaPublicacionDiaria, Publicacion)
        .join(
            subq_max_corte,
            and_(
                MetricaPublicacionDiaria.id_publicacion == subq_max_corte.c.id_publicacion,
                MetricaPublicacionDiaria.fecha_corte == subq_max_corte.c.max_fecha,
            ),
        )
        .join(Publicacion, MetricaPublicacionDiaria.id_publicacion == Publicacion.id_publicacion)
    )
    metricas_query = DataFilterService.apply_real_publicacion_filter(metricas_query)
    metricas_recientes = metricas_query.all()

    total_reacciones_fb = sum(
        m[0].total_reacciones or 0
        for m in metricas_recientes
        if m[1].id_plataforma == 1
    )
    total_likes_ig = sum(
        m[0].total_reacciones or 0
        for m in metricas_recientes
        if m[1].id_plataforma == 2
    )

    total_coms_meta_fb = sum(
        m[0].total_comentarios or 0
        for m in metricas_recientes
        if m[1].id_plataforma == 1
    )
    total_coms_meta_ig = sum(
        m[0].total_comentarios or 0
        for m in metricas_recientes
        if m[1].id_plataforma == 2
    )

    # 4. BUYERS Reales Multicanal (Facebook, Instagram y Landing Page)
    buyers_summary = KpiService.get_multichannel_buyers_summary()

    # 5. Indicadores de Landing Page y Carta Digital (SQL Server)
    landing_metrics = KpiService.get_landing_metrics()

    # 6. Indicadores Estratégicos de Captación BUYER (KPIs)
    kpis_data = KpiService.get_strategic_kpis()

    # 7. Última sincronización registrada
    ultima_sync = (
        AccionAgente.query.filter(
            AccionAgente.accion.in_(["SINCRONIZAR_COORDINADA", "SINCRONIZAR_PUBLICACIONES"])
        )
        .order_by(desc(AccionAgente.fecha_ejecucion))
        .first()
    )

    # 8. Estado de agentes y planificador
    scheduler_status = SyncSchedulerService.get_status()
    coord_status = SyncSchedulerService.get_coordinator().get_status()

    return jsonify({
        "success": True,
        "data": {
            "publicaciones": {
                "facebook": {
                    "total": fb_posts_reales,
                    "reales": fb_posts_reales,
                    "demo": 0,
                },
                "instagram": {
                    "total": ig_posts_reales,
                    "reales": ig_posts_reales,
                    "demo": 0,
                },
                "total_reales": total_posts_reales,
                "total_demo": 0,
            },
            "comentarios": {
                "total": total_comentarios_reales,
                "reales": total_comentarios_reales,
                "demo": 0,
                "facebook": fb_comentarios_capturados,
                "instagram": ig_comentarios_capturados,
            },
            "comentarios_capturados": {
                "facebook": fb_comentarios_capturados,
                "instagram": ig_comentarios_capturados,
                "total": total_comentarios_reales,
            },
            "comentarios_reportados_meta": {
                "facebook": total_coms_meta_fb,
                "instagram": total_coms_meta_ig,
                "total": total_coms_meta_fb + total_coms_meta_ig,
            },
            "reacciones_likes": {
                "facebook": total_reacciones_fb,
                "instagram": total_likes_ig,
                "total": total_reacciones_fb + total_likes_ig,
            },
            "buyers": {
                "total": buyers_summary["total"],
                "reales": buyers_summary["reales"],
                "demo": 0,
                "reales_facebook": buyers_summary["reales_facebook"],
                "reales_instagram": buyers_summary["reales_instagram"],
                "reales_landing": buyers_summary["reales_landing"],
                "personas_landing_unicas": buyers_summary["personas_landing_unicas"],
                "convertidos_lead": buyers_summary["convertidos_lead_personas"],
                "activos": buyers_summary["activos"],
            },
            "landing": landing_metrics,
            "kpis": kpis_data,
            "ultima_sincronizacion": {
                "fecha": ultima_sync.fecha_ejecucion.isoformat() if ultima_sync else None,
                "agente": ultima_sync.nombre_agente if ultima_sync else None,
                "resultado": ultima_sync.resultado if ultima_sync else None,
            },
            "estado_agentes": {
                "scheduler": scheduler_status,
                "coordinador": coord_status.get("coordinador"),
                "facebook": coord_status.get("agente_facebook"),
                "instagram": coord_status.get("agente_instagram"),
            },
        },
    }), 200


@dashboard_bp.route("/api/dashboard/comentarios", methods=["GET"])
def get_dashboard_comentarios():
    """
    Retorna exclusivamente los comentarios reales registrados con su clasificación inteligente de intención.
    Los registros DEMO quedan completamente excluidos de la respuesta, conteos y paginación.
    """
    limit = min(request.args.get("limit", default=100, type=int), 300)
    offset = max(request.args.get("offset", default=0, type=int), 0)
    plat_filtro = request.args.get("plataforma", "").strip().lower()
    intencion_filtro = request.args.get("intencion", "").strip().upper()

    query = (
        InteraccionPublicacion.query.join(Publicacion)
        .join(Plataforma, Publicacion.id_plataforma == Plataforma.id_plataforma)
    )

    # Filtrar solo comentarios e interacciones reales
    query = DataFilterService.apply_real_interaccion_filter(query)
    query = DataFilterService.apply_real_publicacion_filter(query)

    if plat_filtro in ("facebook", "fb"):
        query = query.filter(Publicacion.id_plataforma == 1)
    elif plat_filtro in ("instagram", "ig"):
        query = query.filter(Publicacion.id_plataforma == 2)

    interacciones = query.order_by(desc(InteraccionPublicacion.fecha_interaccion)).all()

    items = []
    for inter in interacciones:
        clasificacion = (
            InterestClassifier.get_clasificacion_comentario(inter.id_interaccion_externa)
            or InterestClassifier.clasificar(inter.texto)
        )

        if intencion_filtro and clasificacion != intencion_filtro:
            continue

        plat_cod = inter.publicacion.plataforma.codigo if (inter.publicacion and inter.publicacion.plataforma) else "DESCONOCIDA"

        items.append({
            "id_interaccion": inter.id_interaccion,
            "id_interaccion_externa": inter.id_interaccion_externa,
            "plataforma": plat_cod,
            "id_publicacion": inter.id_publicacion,
            "meta_post_id": inter.publicacion.meta_post_id if inter.publicacion else None,
            "url_publicacion": inter.publicacion.url_publicacion if inter.publicacion else None,
            "nombre_usuario": inter.nombre_visible or "Usuario anónimo",
            "id_usuario_externo": inter.id_usuario_externo,
            "texto": inter.texto,
            "fecha_interaccion": inter.fecha_interaccion.isoformat() if inter.fecha_interaccion else None,
            "tipo": inter.tipo,
            "id_buyer": inter.id_buyer,
            "clasificacion_intencion": clasificacion,
            "origen": "META_REAL",
        })

    total_filtrado = len(items)
    paginados = items[offset : offset + limit]

    return jsonify({
        "success": True,
        "total": total_filtrado,
        "limit": limit,
        "offset": offset,
        "items": paginados,
    }), 200


@dashboard_bp.route("/api/dashboard/buyers", methods=["GET"])
def get_dashboard_buyers():
    """
    Retorna exclusivamente los prospectos BUYER con procedencia REAL comprobada:
    - Facebook (interacciones en publicaciones oficiales)
    - Instagram (interacciones en media comercial)
    - Landing Page (prospectos web identificados convertidos a LEAD)
    Los prospectos DEMO y sintéticos quedan completamente excluidos.
    """
    limit = min(request.args.get("limit", default=100, type=int), 300)
    offset = max(request.args.get("offset", default=0, type=int), 0)
    plat_filtro = request.args.get("plataforma", "").strip().lower()

    query = Buyer.query.join(Plataforma, Buyer.id_plataforma_origen == Plataforma.id_plataforma)

    # Filtrar solo BUYERS reales (excluye registros DEMO y sintéticos iniciales)
    query = DataFilterService.apply_real_buyer_filter(query)

    if plat_filtro in ("facebook", "fb"):
        query = query.filter(Buyer.id_plataforma_origen == 1)
    elif plat_filtro in ("instagram", "ig"):
        query = query.filter(Buyer.id_plataforma_origen == 2)
    elif plat_filtro in ("landing", "landing_page", "web"):
        query = query.filter(Buyer.id_plataforma_origen == 3)

    total = query.count()
    buyers = query.order_by(desc(Buyer.fecha_primer_contacto)).offset(offset).limit(limit).all()

    # Nombre público del autor: se resuelve en una sola consulta para toda la página.
    # Meta omite el nombre de algunos comentarios, por lo que puede quedar en None.
    nombres_red_social: dict[int, str] = {}
    ids_buyers = [b.id_buyer for b in buyers]
    if ids_buyers:
        nombres_query = db.session.query(
            InteraccionPublicacion.id_buyer,
            InteraccionPublicacion.nombre_visible,
        ).filter(
            InteraccionPublicacion.id_buyer.in_(ids_buyers),
            InteraccionPublicacion.nombre_visible.isnot(None),
            InteraccionPublicacion.nombre_visible != "",
        )
        nombres_query = DataFilterService.apply_real_interaccion_filter(nombres_query)
        for id_buyer, nombre in nombres_query.order_by(
            desc(InteraccionPublicacion.fecha_interaccion)
        ).all():
            nombres_red_social.setdefault(id_buyer, nombre)

    items = []
    for b in buyers:
        # Calcular interacciones según el canal de origen
        if b.id_plataforma_origen in (1, 2):
            cant_interacciones = (
                InteraccionPublicacion.query.filter(
                    InteraccionPublicacion.id_buyer == b.id_buyer,
                    ~InteraccionPublicacion.id_interaccion_externa.like("DEMO_%"),
                ).count()
            )
            origen_str = "META_REAL"
        elif b.id_plataforma_origen == 3:
            cant_interacciones = (
                VisitaWeb.query.filter(VisitaWeb.id_buyer == b.id_buyer).count()
                + FormularioCaptacion.query.filter(FormularioCaptacion.id_buyer == b.id_buyer).count()
            )
            origen_str = "LANDING_PAGE"
        else:
            cant_interacciones = 0
            origen_str = "OTRO"

        nombre_persona = (
            f"{b.persona.nombres} {b.persona.apellidos}".strip() if b.persona else None
        )
        nombre_usuario = nombre_persona or nombres_red_social.get(b.id_buyer)

        items.append({
            "id_buyer": b.id_buyer,
            "id_persona": b.id_persona,
            "persona_nombre": nombre_persona,
            "nombre_usuario": nombre_usuario,
            "nombre_usuario_fuente": (
                "PERSONA" if nombre_persona else ("RED_SOCIAL" if nombre_usuario else None)
            ),
            "id_plataforma_origen": b.id_plataforma_origen,
            "plataforma_codigo": b.plataforma_origen.codigo if b.plataforma_origen else "DESCONOCIDA",
            "id_publicacion_origen": b.id_publicacion_origen,
            "meta_post_id_origen": b.publicacion_origen.meta_post_id if b.publicacion_origen else None,
            "url_publicacion_origen": b.publicacion_origen.url_publicacion if b.publicacion_origen else None,
            "referencia_externa_enmascarada": mask_external_ref(b.referencia_externa),
            "fecha_primer_contacto": b.fecha_primer_contacto.isoformat() if b.fecha_primer_contacto else None,
            "estado": b.estado,
            "total_interacciones": cant_interacciones,
            "origen": origen_str,
        })

    return jsonify({
        "success": True,
        "total": total,
        "limit": limit,
        "offset": offset,
        "items": items,
    }), 200


@dashboard_bp.route("/api/dashboard/kpis", methods=["GET"])
@dashboard_bp.route("/api/kpis", methods=["GET"])
def get_dashboard_kpis():
    """
    Retorna los tres Indicadores Estratégicos de Captación BUYER:
    1. CPA: Costo por Anuncio / Lead (MIXTO: gasto simulado / LEADS reales)
    2. TMD: Tasa de Interés en Menú Digital (REAL)
    3. B1: Tasa de Conversión BUYER a LEAD (REAL)
    Soporta filtros de período: ?periodo=todo|hoy|7dias|30dias
    """
    periodo = request.args.get("periodo")
    f_ini = request.args.get("fecha_inicio")
    f_fin = request.args.get("fecha_fin")
    ini, fin, label = KpiService.parse_date_range(periodo, f_ini, f_fin)
    kpis = KpiService.get_strategic_kpis(ini, fin, label)
    return jsonify({
        "success": True,
        "data": kpis,
    }), 200
