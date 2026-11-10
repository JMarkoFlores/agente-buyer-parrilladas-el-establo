"""
Blueprint para consulta de BUYERS y prospectos captados.
GET /api/buyers
GET /api/buyers/<id_buyer>
"""
from flask import Blueprint, jsonify, request
from app.services.buyer_service import BuyerService

buyers_bp = Blueprint("buyers", __name__)
service = BuyerService()


@buyers_bp.route("/buyers", methods=["GET"])
def get_buyers():
    """
    Lista los BUYERS captados por los distintos canales del restaurante.
    Filtros y paginación:
    - ?estado=BUYER|CONVERTIDO_LEAD|DESCARTADO
    - ?id_plataforma=<int>
    - ?page=<int, default 1>
    - ?page_size=<int, default 20>
    """
    estado = request.args.get("estado")
    id_plataforma = request.args.get("id_plataforma", type=int)
    page = request.args.get("page", default=1, type=int)
    page_size = request.args.get("page_size", default=20, type=int)

    result = service.list_buyers(
        estado=estado,
        id_plataforma=id_plataforma,
        page=page,
        page_size=page_size,
    )
    return jsonify({
        "success": True,
        **result,
    }), 200


@buyers_bp.route("/buyers/<int:id_buyer>", methods=["GET"])
def get_buyer_by_id(id_buyer: int):
    """
    Obtiene el detalle de un BUYER por su ID.
    """
    item = service.get_buyer_by_id(id_buyer)
    if not item:
        return jsonify({
            "success": False,
            "error": "BUYER no encontrado",
            "id_buyer": id_buyer,
        }), 404

    return jsonify({
        "success": True,
        "data": item,
    }), 200
