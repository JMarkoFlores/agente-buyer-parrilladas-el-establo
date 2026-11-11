"""
Blueprint para endpoints de la integración de Facebook:
- GET  /api/facebook/status
- POST /api/facebook/sincronizar (Protegido por token de administración)
- GET  /api/facebook/publicaciones
- GET  /api/facebook/publicaciones/<id>/comentarios
- GET  /api/facebook/metricas
"""
from __future__ import annotations

import hmac
from functools import wraps
from flask import Blueprint, jsonify, request, current_app
from app.services.facebook_service import FacebookService

facebook_bp = Blueprint("facebook", __name__)
service = FacebookService()


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

        # Extraer token enviado por diversos mecanismos
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


@facebook_bp.route("/status", methods=["GET"])
def get_status():
    """
    Verifica la conexión real con Meta Graph API y reporta permisos y capacidades.
    NUNCA expone el token de acceso en texto claro.
    """
    status_data = service.get_status()
    status_code = 200 if status_data.get("conectado") else 200
    # Devolver 200 con la información del estado, distinguiendo si está conectado o no
    return jsonify({
        "success": True,
        "data": status_data,
    }), status_code


@facebook_bp.route("/sincronizar", methods=["POST"])
@require_admin_auth
def sincronizar():
    """
    Ejecuta la sincronización manual de publicaciones, comentarios y métricas desde Meta hacia SQL Server.
    Protegido por token de administración local.
    Devuelve los totales de registros nuevos, actualizados, omitidos y fallidos.
    """
    resultado = service.sincronizar()
    if not resultado.get("success"):
        return jsonify(resultado), 400
    return jsonify(resultado), 200


@facebook_bp.route("/publicaciones", methods=["GET"])
def get_publicaciones():
    """
    Lista las publicaciones de Facebook almacenadas en la base de datos SQL Server.
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


@facebook_bp.route("/publicaciones/<int:id_publicacion>/comentarios", methods=["GET"])
def get_comentarios(id_publicacion: int):
    """
    Obtiene los comentarios e interacciones de una publicación específica de Facebook.
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


@facebook_bp.route("/metricas", methods=["GET"])
def get_metricas():
    """
    Obtiene el historial de métricas diarias de publicaciones de Facebook.
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
