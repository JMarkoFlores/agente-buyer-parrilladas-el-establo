"""
Blueprint para consulta de campañas publicitarias.
GET /api/campanas
GET /api/campanas/<id_campana>
"""
from flask import Blueprint, jsonify, request
from app.services.catalog_service import CatalogService

campanas_bp = Blueprint("campanas", __name__)
service = CatalogService()


@campanas_bp.route("/campanas", methods=["GET"])
def get_campanas():
    """
    Lista las campañas publicitarias.
    Filtros opcionales:
    - ?activa=true|false
    - ?id_plataforma=<int>
    """
    activa_param = request.args.get("activa")
    activa_filter = None
    if activa_param is not None:
        activa_filter = activa_param.lower() in ("true", "1", "yes")

    id_plataforma = request.args.get("id_plataforma", type=int)

    items = service.list_campanas(activa=activa_filter, id_plataforma=id_plataforma)
    return jsonify({
        "success": True,
        "total": len(items),
        "data": items,
    }), 200


@campanas_bp.route("/campanas/<int:id_campana>", methods=["GET"])
def get_campana_by_id(id_campana: int):
    """
    Obtiene los detalles de una campaña publicitaria por su ID.
    """
    item = service.get_campana(id_campana)
    if not item:
        return jsonify({
            "success": False,
            "error": "Campaña no encontrada",
            "id_campana": id_campana,
        }), 404

    return jsonify({
        "success": True,
        "data": item,
    }), 200
