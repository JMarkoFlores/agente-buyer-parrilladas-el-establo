"""
Rutas del Dashboard Web y Endpoints Analíticos:
- GET /dashboard               -> Interfaz web local interactiva (Jinja2 + Bootstrap)
- GET /api/dashboard/resumen   -> Resumen consolidado (mide datos reales vs DEMO)
- GET /api/dashboard/comentarios -> Tabla de comentarios con clasificación de intención
- GET /api/dashboard/buyers    -> Tabla de BUYERS con procedencia e interacciones
"""
from __future__ import annotations

from datetime import datetime
from typing import Any
from flask import Blueprint, jsonify, render_template, request, current_app, redirect, url_for
from sqlalchemy import func, desc

from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import AccionAgente
from app.services.interest_classifier import InterestClassifier
from app.services.sync_scheduler import SyncSchedulerService

dashboard_bp = Blueprint("dashboard", __name__)


def _es_demo_post(meta_post_id: str | None) -> bool:
    return bool(meta_post_id and meta_post_id.startswith("DEMO_"))


def _es_demo_buyer(referencia_externa: str | None) -> bool:
    if not referencia_externa:
        return False
    ref = referencia_externa.upper()
    return ref.startswith("DEMO_") or ref.startswith("COOKIE_")


def _es_demo_comentario(id_interaccion_ext: str | None) -> bool:
    return bool(id_interaccion_ext and id_interaccion_ext.startswith("DEMO_"))


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
    Retorna métricas consolidadas distinguiendo rigurosamente registros REALES de DEMO:
    - Publicaciones Facebook e Instagram
    - Comentarios
    - Likes / reacciones
    - BUYERS identificados
    - Última sincronización y estado de agentes
    """
    # 1. Publicaciones
    posts = Publicacion.query.all()
    fb_posts_reales = sum(1 for p in posts if p.id_plataforma == 1 and not _es_demo_post(p.meta_post_id))
    fb_posts_demo = sum(1 for p in posts if p.id_plataforma == 1 and _es_demo_post(p.meta_post_id))
    ig_posts_reales = sum(1 for p in posts if p.id_plataforma == 2 and not _es_demo_post(p.meta_post_id))
    ig_posts_demo = sum(1 for p in posts if p.id_plataforma == 2 and _es_demo_post(p.meta_post_id))

    # 2. Comentarios
    comentarios = InteraccionPublicacion.query.all()
    total_comentarios = len(comentarios)
    comentarios_reales = sum(1 for c in comentarios if not _es_demo_comentario(c.id_interaccion_externa))
    comentarios_demo = sum(1 for c in comentarios if _es_demo_comentario(c.id_interaccion_externa))

    # 3. Likes y métricas agregadas (último corte por publicación)
    subq = (
        db.session.query(
            MetricaPublicacionDiaria.id_publicacion,
            func.max(MetricaPublicacionDiaria.fecha_corte).label("max_fecha"),
        )
        .group_by(MetricaPublicacionDiaria.id_publicacion)
        .subquery()
    )

    metricas_recientes = (
        db.session.query(MetricaPublicacionDiaria)
        .join(
            subq,
            (MetricaPublicacionDiaria.id_publicacion == subq.c.id_publicacion)
            & (MetricaPublicacionDiaria.fecha_corte == subq.c.max_fecha),
        )
        .all()
    )

    total_likes_fb = sum(
        m.total_reacciones or 0
        for m in metricas_recientes
        if m.publicacion and m.publicacion.id_plataforma == 1
    )
    total_likes_ig = sum(
        m.total_reacciones or 0
        for m in metricas_recientes
        if m.publicacion and m.publicacion.id_plataforma == 2
    )

    # 4. BUYERS
    buyers = Buyer.query.all()
    total_buyers = len(buyers)
    buyers_reales = sum(1 for b in buyers if not _es_demo_buyer(b.referencia_externa))
    buyers_demo = sum(1 for b in buyers if _es_demo_buyer(b.referencia_externa))

    buyers_fb = sum(1 for b in buyers if b.id_plataforma_origen == 1 and not _es_demo_buyer(b.referencia_externa))
    buyers_ig = sum(1 for b in buyers if b.id_plataforma_origen == 2 and not _es_demo_buyer(b.referencia_externa))

    # 5. Última sincronización registrada
    ultima_sync = (
        AccionAgente.query.filter(
            AccionAgente.accion.in_(["SINCRONIZAR_COORDINADA", "SINCRONIZAR_PUBLICACIONES"])
        )
        .order_by(desc(AccionAgente.fecha_ejecucion))
        .first()
    )

    # 6. Estado de agentes y planificador
    scheduler_status = SyncSchedulerService.get_status()
    coord_status = SyncSchedulerService.get_coordinator().get_status()

    return jsonify({
        "success": True,
        "data": {
            "publicaciones": {
                "facebook": {
                    "total": fb_posts_reales + fb_posts_demo,
                    "reales": fb_posts_reales,
                    "demo": fb_posts_demo,
                },
                "instagram": {
                    "total": ig_posts_reales + ig_posts_demo,
                    "reales": ig_posts_reales,
                    "demo": ig_posts_demo,
                },
                "total_reales": fb_posts_reales + ig_posts_reales,
                "total_demo": fb_posts_demo + ig_posts_demo,
            },
            "comentarios": {
                "total": total_comentarios,
                "reales": comentarios_reales,
                "demo": comentarios_demo,
            },
            "reacciones_likes": {
                "facebook": total_likes_fb,
                "instagram": total_likes_ig,
                "total": total_likes_fb + total_likes_ig,
            },
            "buyers": {
                "total": total_buyers,
                "reales": buyers_reales,
                "demo": buyers_demo,
                "reales_facebook": buyers_fb,
                "reales_instagram": buyers_ig,
            },
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
    Retorna los comentarios registrados con su clasificación inteligente de intención.
    Parámetros opcionales:
    - plataforma: 'facebook', 'instagram' o None (todas)
    - limit: int (default 100)
    - offset: int (default 0)
    - intencion: filtro por categoría de intención
    """
    limit = min(request.args.get("limit", default=100, type=int), 300)
    offset = max(request.args.get("offset", default=0, type=int), 0)
    plat_filtro = request.args.get("plataforma", "").strip().lower()
    intencion_filtro = request.args.get("intencion", "").strip().upper()

    query = (
        InteraccionPublicacion.query.join(Publicacion)
        .join(Plataforma, Publicacion.id_plataforma == Plataforma.id_plataforma)
    )

    if plat_filtro in ("facebook", "fb"):
        query = query.filter(Publicacion.id_plataforma == 1)
    elif plat_filtro in ("instagram", "ig"):
        query = query.filter(Publicacion.id_plataforma == 2)

    interacciones = query.order_by(desc(InteraccionPublicacion.fecha_interaccion)).all()

    items = []
    for inter in interacciones:
        # Consultar o inferir clasificación
        clasificacion = (
            InterestClassifier.get_clasificacion_comentario(inter.id_interaccion_externa)
            or InterestClassifier.clasificar(inter.texto)
        )

        if intencion_filtro and clasificacion != intencion_filtro:
            continue

        plat_cod = inter.publicacion.plataforma.codigo if (inter.publicacion and inter.publicacion.plataforma) else "DESCONOCIDA"
        es_demo = _es_demo_comentario(inter.id_interaccion_externa)

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
            "origen": "DEMO" if es_demo else "META_REAL",
        })

    # Paginación en memoria sobre el conjunto filtrado
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
    Retorna la lista de prospectos BUYER con su plataforma de origen, estado
    y conteo de interacciones sin exponer datos personales innecesarios.
    """
    limit = min(request.args.get("limit", default=100, type=int), 300)
    offset = max(request.args.get("offset", default=0, type=int), 0)
    plat_filtro = request.args.get("plataforma", "").strip().lower()

    query = Buyer.query.join(Plataforma, Buyer.id_plataforma_origen == Plataforma.id_plataforma)

    if plat_filtro in ("facebook", "fb"):
        query = query.filter(Buyer.id_plataforma_origen == 1)
    elif plat_filtro in ("instagram", "ig"):
        query = query.filter(Buyer.id_plataforma_origen == 2)

    total = query.count()
    buyers = query.order_by(desc(Buyer.fecha_primer_contacto)).offset(offset).limit(limit).all()

    items = []
    for b in buyers:
        # Contar interacciones asociadas
        cant_interacciones = InteraccionPublicacion.query.filter(
            InteraccionPublicacion.id_buyer == b.id_buyer
        ).count()

        es_demo = _es_demo_buyer(b.referencia_externa)

        items.append({
            "id_buyer": b.id_buyer,
            "id_plataforma_origen": b.id_plataforma_origen,
            "plataforma_codigo": b.plataforma_origen.codigo if b.plataforma_origen else "DESCONOCIDA",
            "id_publicacion_origen": b.id_publicacion_origen,
            "meta_post_id_origen": b.publicacion_origen.meta_post_id if b.publicacion_origen else None,
            "url_publicacion_origen": b.publicacion_origen.url_publicacion if b.publicacion_origen else None,
            "referencia_externa_enmascarada": (
                b.referencia_externa[:4] + "***" + b.referencia_externa[-4:]
                if b.referencia_externa and len(b.referencia_externa) > 8
                else b.referencia_externa
            ),
            "fecha_primer_contacto": b.fecha_primer_contacto.isoformat() if b.fecha_primer_contacto else None,
            "estado": b.estado,
            "total_interacciones": cant_interacciones,
            "origen": "DEMO" if es_demo else "META_REAL",
        })

    return jsonify({
        "success": True,
        "total": total,
        "limit": limit,
        "offset": offset,
        "items": items,
    }), 200
