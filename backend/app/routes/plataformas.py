"""
Blueprint para consulta de plataformas digitales.
GET /api/plataformas
GET /api/plataformas/<id_plataforma>
"""
from flask import Blueprint, jsonify, request
from app.services.catalog_service import CatalogService

plataformas_bp = Blueprint("plataformas", __name__)
service = CatalogService()


@plataformas_bp.route("/plataformas", methods=["GET"])
def get_plataformas():
    """
    Lista las plataformas de captación (FACEBOOK, INSTAGRAM, LANDING_PAGE, WHATSAPP).
    Filtro opcional: ?activa=true|false
    """
    activa_param = request.args.get("activa")
    activa_filter = None
    if activa_param is not None:
        activa_filter = activa_param.lower() in ("true", "1", "yes")

    items = service.list_plataformas(activa=activa_filter)
    return jsonify({
        "success": True,
        "total": len(items),
        "data": items,
    }), 200


@plataformas_bp.route("/plataformas/<int:id_plataforma>", methods=["GET"])
def get_plataforma_by_id(id_plataforma: int):
    """
    Obtiene los detalles de una plataforma específica por su identificador.
    """
    item = service.get_plataforma(id_plataforma)
    if not item:
        return jsonify({
            "success": False,
            "error": "Plataforma no encontrada",
            "id_plataforma": id_plataforma,
        }), 404

    return jsonify({
        "success": True,
        "data": item,
    }), 200
