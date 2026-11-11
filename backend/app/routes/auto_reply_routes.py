"""
Blueprint de rutas para el Agente de Respuestas Automáticas:
- GET  /api/respuestas/status       -> Configuración activa y contadores de respuestas
- GET  /api/respuestas/pendientes   -> Respuestas pendientes que requieren revisión
- GET  /api/respuestas/historial    -> Historial completo de respuestas filtradas
- POST /api/respuestas/generar      -> Evaluación de comentarios y generación de propuestas
- POST /api/respuestas/<id>/aprobar -> Aprobación manual de propuesta (con opción a editar)
- POST /api/respuestas/<id>/enviar  -> Envío hacia Meta Graph API o simulación (Dry Run)
- POST /api/respuestas/<id>/rechazar-> Rechazo / omisión de propuesta
"""
from __future__ import annotations

import hmac
from functools import wraps
from flask import Blueprint, jsonify, request, current_app

from app.services.auto_reply_service import AutoReplyService

auto_reply_bp = Blueprint("auto_reply", __name__)
service = AutoReplyService()


def require_admin_auth(f):
    """
    Decorador para proteger operaciones de aprobación y envío de respuestas.
    Verifica ADMIN_API_KEY o SECRET_KEY.
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

        # En entorno de pruebas o desarrollo, si no se configuró ADMIN_API_KEY, permitir
        if not expected_key:
            return f(*args, **kwargs)

        if not provided_token or not hmac.compare_digest(provided_token, expected_key):
            return jsonify({
                "success": False,
                "error": "No autorizado: se requiere autenticación de administración válida.",
                "instruccion": "Envíe el token configurado en el header 'X-Admin-Token', 'X-API-Key' o 'Authorization: Bearer <token>'.",
            }), 401

        return f(*args, **kwargs)
    return decorated_function


@auto_reply_bp.route("/status", methods=["GET"])
def get_status():
    """Retorna la configuración activa y métricas consolidadas del agente de respuestas."""
    data = service.get_status()
    return jsonify({
        "success": True,
        "data": data,
    }), 200


@auto_reply_bp.route("/pendientes", methods=["GET"])
def get_pendientes():
    """Lista las propuestas de respuestas en estado PENDIENTE o REQUIERE_REVISION."""
    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)
    plataforma = request.args.get("plataforma", default=None, type=str)

    data = service.list_respuestas(estado="PENDIENTE", plataforma=plataforma, limit=limit, offset=offset)
    return jsonify({
        "success": True,
        "total": data["total"],
        "limit": data["limit"],
        "offset": data["offset"],
        "data": data["items"],
    }), 200


@auto_reply_bp.route("/historial", methods=["GET"])
def get_historial():
    """Lista el historial de respuestas con filtros por estado y plataforma."""
    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)
    estado = request.args.get("estado", default=None, type=str)
    plataforma = request.args.get("plataforma", default=None, type=str)

    data = service.list_respuestas(estado=estado, plataforma=plataforma, limit=limit, offset=offset)
    return jsonify({
        "success": True,
        "total": data["total"],
        "limit": data["limit"],
        "offset": data["offset"],
        "data": data["items"],
    }), 200


@auto_reply_bp.route("/trazabilidad", methods=["GET"])
def get_trazabilidad():
    """
    Retorna la trazabilidad detallada de comentarios analizados por el agente:
    respondidos, simulados, pendientes, omitidos por regla o bloqueados por cooldown.
    """
    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)
    filtro_estado = request.args.get("estado", default=None, type=str)
    plataforma = request.args.get("plataforma", default=None, type=str)

    data = service.obtener_trazabilidad_comentarios(
        limite=limit,
        offset=offset,
        filtro_estado=filtro_estado,
        plataforma=plataforma,
    )
    return jsonify({
        "success": True,
        "data": data,
    }), 200


@auto_reply_bp.route("/generar", methods=["POST"])
@require_admin_auth
def generar():
    """Ejecuta la evaluación de comentarios nuevos y genera propuestas de respuestas."""
    max_comentarios = request.args.get("max", default=None, type=int)
    if request.is_json and request.get_json(silent=True):
        body = request.get_json(silent=True) or {}
        max_comentarios = body.get("max", max_comentarios)

    resultado = service.procesar_comentarios_nuevos(max_comentarios=max_comentarios)
    return jsonify(resultado), 200


@auto_reply_bp.route("/<int:id_respuesta>/aprobar", methods=["POST"])
@require_admin_auth
def aprobar(id_respuesta: int):
    """Aprueba una propuesta de respuesta (con opción de edición)."""
    body = request.get_json(silent=True) or {} if request.is_json else {}
    texto_editado = body.get("texto_respuesta")

    resultado = service.aprobar_respuesta(id_respuesta=id_respuesta, texto_editado=texto_editado)
    if not resultado.get("success"):
        return jsonify(resultado), 400
    return jsonify(resultado), 200


@auto_reply_bp.route("/<int:id_respuesta>/rechazar", methods=["POST"])
@require_admin_auth
def rechazar(id_respuesta: int):
    """Rechaza / omite una propuesta de respuesta."""
    body = request.get_json(silent=True) or {} if request.is_json else {}
    motivo = body.get("motivo")

    resultado = service.rechazar_respuesta(id_respuesta=id_respuesta, motivo=motivo)
    if not resultado.get("success"):
        return jsonify(resultado), 400
    return jsonify(resultado), 200


@auto_reply_bp.route("/<int:id_respuesta>/enviar", methods=["POST"])
@require_admin_auth
def enviar(id_respuesta: int):
    """Despacha la respuesta hacia Meta Graph API o ejecuta la simulación (DRY RUN)."""
    resultado = service.enviar_respuesta(id_respuesta=id_respuesta)
    if not resultado.get("success"):
        return jsonify(resultado), 400
    return jsonify(resultado), 200


@auto_reply_bp.route("/emergency-stop", methods=["POST"])
@require_admin_auth
def emergency_stop():
    """Desactiva inmediatamente el envío automático de respuestas (Kill Switch de Emergencia)."""
    body = request.get_json(silent=True) or {} if request.is_json else {}
    motivo = body.get("motivo", "Parada de emergencia ejecutada desde la API")
    status = service.desactivar_envio_automatico(motivo=motivo)
    return jsonify({
        "success": True,
        "mensaje": "Envío automático DESACTIVADO de emergencia exitosamente.",
        "data": status,
    }), 200


@auto_reply_bp.route("/activar-auto", methods=["POST"])
@require_admin_auth
def activar_auto():
    """Activa el modo de envío automático continuo sin aprobación previa."""
    status = service.activar_envio_automatico()
    return jsonify({
        "success": True,
        "mensaje": "Envío automático ACTIVADO exitosamente.",
        "data": status,
    }), 200
