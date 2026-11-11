"""
Blueprint para endpoints de la integración de Instagram:
- GET  /api/instagram/status
- POST /api/instagram/sincronizar (Protegido por token de administración)
- GET  /api/instagram/publicaciones
- GET  /api/instagram/publicaciones/<id>/comentarios
- GET  /api/instagram/metricas
"""
from __future__ import annotations

import hmac
from functools import wraps
from flask import Blueprint, jsonify, request, current_app
from app.services.instagram_service import InstagramService

instagram_bp = Blueprint("instagram", __name__)
service = InstagramService()


def require_admin_auth(f):
    """
    Decorador para proteger la sincronización manual mediante autenticación local de administración.
    Admite encabezados X-Admin-Token, X-API-Key, Authorization: Bearer <token>, cuerpo JSON o parámetro ?admin_key=.
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


@instagram_bp.route("/status", methods=["GET"])
def get_status():
    """
    Verifica la conexión real con Meta Graph API para Instagram y reporta información de la cuenta.
    NUNCA expone el token de acceso en texto claro.
    """
    status_data = service.get_status()
    return jsonify({
        "success": True,
        "data": status_data,
    }), 200


@instagram_bp.route("/sincronizar", methods=["POST"])
@require_admin_auth
def sincronizar():
    """
    Ejecuta la sincronización manual de publicaciones, comentarios y métricas desde Instagram hacia SQL Server.
    Protegido por token de administración local.
    Devuelve los totales de registros nuevos, actualizados, omitidos y fallidos.
    """
    resultado = service.sincronizar()
    if not resultado.get("success"):
        return jsonify(resultado), 400
    return jsonify(resultado), 200


@instagram_bp.route("/publicaciones", methods=["GET"])
def get_publicaciones():
    """
    Lista las publicaciones de Instagram almacenadas en la base de datos SQL Server.
    Parámetros opcionales: ?limit=<int>&offset=<int>
    """
    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)

    data = service.list_publicaciones(limit=limit, offset=offset)
    return jsonify({
        "success": True,
        "total": data["total"],
        "limit": data["limit"],
        "offset": data["offset"],
        "data": data["items"],
    }), 200


@instagram_bp.route("/publicaciones/<int:id_publicacion>/comentarios", methods=["GET"])
def get_comentarios(id_publicacion: int):
    """
    Obtiene los comentarios de una publicación específica de Instagram.
    """
    limit = request.args.get("limit", default=100, type=int)
    offset = request.args.get("offset", default=0, type=int)

    data = service.list_comentarios(id_publicacion=id_publicacion, limit=limit, offset=offset)
    if data is None:
        return jsonify({
            "success": False,
            "error": "Publicación no encontrada",
            "id_publicacion": id_publicacion,
        }), 404

    return jsonify({
        "success": True,
        "data": data,
    }), 200


@instagram_bp.route("/metricas", methods=["GET"])
def get_metricas():
    """
    Obtiene el historial de métricas diarias de publicaciones de Instagram.
    Parámetros opcionales: ?id_publicacion=<int>&limit=<int>&offset=<int>
    """
    id_pub = request.args.get("id_publicacion", type=int)
    limit = request.args.get("limit", default=50, type=int)
    offset = request.args.get("offset", default=0, type=int)

    data = service.list_metricas(id_publicacion=id_pub, limit=limit, offset=offset)
    return jsonify({
        "success": True,
        "total": data["total"],
        "limit": data["limit"],
        "offset": data["offset"],
        "data": data["items"],
    }), 200
