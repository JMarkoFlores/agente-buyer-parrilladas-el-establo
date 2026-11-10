"""
Blueprint para consulta de productos de la carta.
GET /api/productos
GET /api/productos/<id_producto>
"""
from flask import Blueprint, jsonify, request
from app.services.catalog_service import CatalogService

productos_bp = Blueprint("productos", __name__)
service = CatalogService()


@productos_bp.route("/productos", methods=["GET"])
def get_productos():
    """
    Lista los productos gastronómicos de Parrilladas El Establo.
    Filtros opcionales:
    - ?categoria=COMIDA|BEBIDA|POSTRE
    - ?activo=true|false
    """
    categoria = request.args.get("categoria")
    activo_param = request.args.get("activo")
    activo_filter = None
    if activo_param is not None:
        activo_filter = activo_param.lower() in ("true", "1", "yes")

    items = service.list_productos(categoria=categoria, activo=activo_filter)
    return jsonify({
        "success": True,
        "total": len(items),
        "data": items,
    }), 200


@productos_bp.route("/productos/<int:id_producto>", methods=["GET"])
def get_producto_by_id(id_producto: int):
    """
    Obtiene un producto específico por su identificador.
    """
    item = service.get_producto(id_producto)
    if not item:
        return jsonify({
            "success": False,
            "error": "Producto no encontrado",
            "id_producto": id_producto,
        }), 404

    return jsonify({
        "success": True,
        "data": item,
    }), 200
