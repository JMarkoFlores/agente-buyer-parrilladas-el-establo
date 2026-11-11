"""
Rutas para la gestión y consulta de Agentes Inteligentes:
- GET  /api/agentes/status      -> Estado de agentes, scheduler y conexiones
- POST /api/agentes/sincronizar -> Ejecuta sincronización coordinada (Requiere ADMIN_API_KEY)
- GET  /api/agentes/actividad   -> Registro histórico de auditoría de agentes en dbo.accion_agente
"""
from __future__ import annotations

import hmac
from functools import wraps
from flask import Blueprint, jsonify, request, current_app
from sqlalchemy import desc

from app.services.sync_scheduler import SyncSchedulerService
from app.agents.buyer_coordinator import SincronizacionEnCursoError
from app.models.auditoria import AccionAgente
from app.services.data_filter_service import DataFilterService

agentes_bp = Blueprint("agentes", __name__)


def require_admin_auth(f):
    """
    Decorador para proteger endpoints administrativos mediante clave ADMIN_API_KEY.
    Acepta:
    - Encabezado 'X-Admin-Token'
    - Encabezado 'X-API-Key'
    - Encabezado 'Authorization: Bearer <token>'
    - Parámetro en query ?admin_key=
    - Cuerpo JSON {"admin_key": "..."}
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        expected_key = current_app.config.get("ADMIN_API_KEY", "").strip()
        if not expected_key:
            expected_key = current_app.config.get("SECRET_KEY", "").strip()

        auth_header = request.headers.get("Authorization", "")
        admin_token_header = request.headers.get("X-Admin-Token", "").strip()
        api_key_header = request.headers.get("X-API-Key", "").strip()
        query_key = request.args.get("admin_key", "").strip() or request.args.get("api_key", "").strip()

        json_key = ""
        if request.is_json and request.get_json(silent=True):
            body = request.get_json(silent=True) or {}
            json_key = str(body.get("admin_key") or body.get("admin_token") or body.get("api_key") or "").strip()

        provided_token = (
            admin_token_header
            or api_key_header
            or json_key
            or query_key
            or (auth_header[7:].strip() if auth_header.startswith("Bearer ") else "")
        )

        if not provided_token or not hmac.compare_digest(provided_token, expected_key):
            return jsonify({
                "success": False,
                "error": "No autorizado: se requiere autenticación de administración válida.",
                "instruccion": "Envíe el token configurado en el header 'X-Admin-Token', 'X-API-Key' o 'Authorization: Bearer <token>'.",
            }), 401

        return f(*args, **kwargs)
    return decorated_function


@agentes_bp.route("/status", methods=["GET"])
def get_agentes_status():
    """
    Reporta el estado general del ecosistema de agentes:
    - Agente Coordinador
    - Agente Facebook
    - Agente Instagram
    - Planificador (Scheduler)
    """
    status_scheduler = SyncSchedulerService.get_status()
    coord = SyncSchedulerService.get_coordinator()
    status_coord = coord.get_status()

    return jsonify({
        "success": True,
        "data": {
            "scheduler": status_scheduler,
            "coordinador": status_coord.get("coordinador"),
            "agente_facebook": status_coord.get("agente_facebook"),
            "agente_instagram": status_coord.get("agente_instagram"),
        },
    }), 200


@agentes_bp.route("/sincronizar", methods=["POST"])
@require_admin_auth
def sincronizar_coordinado():
    """
    Dispara una sincronización coordinada manual.
    Parámetro opcional:
    - plataforma: 'todas' (default), 'facebook' o 'instagram'.
    Protegido por ADMIN_API_KEY.
    """
    body = request.get_json(silent=True) or {}
    plataforma = (
        request.args.get("plataforma")
        or body.get("plataforma")
        or "todas"
    )

    coord = SyncSchedulerService.get_coordinator()

    try:
        resultado = coord.sincronizar(plataforma=plataforma, clasificar_comentarios=True)
        status_code = 200 if resultado.get("success") else 400
        return jsonify(resultado), status_code
    except SincronizacionEnCursoError as exc:
        return jsonify({
            "success": False,
            "error": str(exc),
            "codigo": "CONCURRENCIA_BLOQUEADA",
        }), 409
    except Exception as exc:
        return jsonify({
            "success": False,
            "error": f"Error inesperado durante la sincronización: {str(exc)}",
        }), 500


@agentes_bp.route("/actividad", methods=["GET"])
def get_actividad_agentes():
    """
    Consulta el historial de acciones y auditoría de los agentes en dbo.accion_agente.
    Parámetros opcionales:
    - limit: int (default: 50, máx: 200)
    - offset: int (default: 0)
    - agente: str (filtra por nombre_agente)
    - accion: str (filtra por tipo de acción)
    - resultado: str (EXITOSO, FALLIDO, PENDIENTE)
    """
    limit = min(request.args.get("limit", default=50, type=int), 200)
    offset = max(request.args.get("offset", default=0, type=int), 0)
    agente_filtro = request.args.get("agente", "").strip()
    accion_filtro = request.args.get("accion", "").strip()
    resultado_filtro = request.args.get("resultado", "").strip().upper()

    query = AccionAgente.query
    query = DataFilterService.apply_real_accion_filter(query)

    if agente_filtro:
        query = query.filter(AccionAgente.nombre_agente == agente_filtro)
    if accion_filtro:
        query = query.filter(AccionAgente.accion == accion_filtro)
    if resultado_filtro:
        query = query.filter(AccionAgente.resultado == resultado_filtro)

    total = query.count()
    items = query.order_by(desc(AccionAgente.fecha_ejecucion)).offset(offset).limit(limit).all()

    return jsonify({
        "success": True,
        "total": total,
        "limit": limit,
        "offset": offset,
        "items": [item.to_dict() for item in items],
    }), 200
