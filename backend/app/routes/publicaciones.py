"""
Blueprint para consulta de publicaciones publicitarias en redes.
GET /api/publicaciones
GET /api/publicaciones/<id_publicacion>
"""
from flask import Blueprint, jsonify, request
from app.services.catalog_service import CatalogService

publicaciones_bp = Blueprint("publicaciones", __name__)
service = CatalogService()


@publicaciones_bp.route("/publicaciones", methods=["GET"])
def get_publicaciones():
    """
    Lista publicaciones realizadas en plataformas (Meta, etc.).
    Filtros opcionales:
    - ?id_plataforma=<int>
    - ?id_campana=<int>
    - ?estado=PROGRAMADA|PUBLICADA|ARCHIVADA
    """
    id_plataforma = request.args.get("id_plataforma", type=int)
    id_campana = request.args.get("id_campana", type=int)
    estado = request.args.get("estado")

    items = service.list_publicaciones(
        id_plataforma=id_plataforma,
        id_campana=id_campana,
        estado=estado,
    )
    return jsonify({
        "success": True,
        "total": len(items),
        "data": items,
    }), 200


@publicaciones_bp.route("/publicaciones/<int:id_publicacion>", methods=["GET"])
def get_publicacion_by_id(id_publicacion: int):
    """
    Obtiene una publicación específica por su ID.
    """
    item = service.get_publicacion(id_publicacion)
    if not item:
        return jsonify({
            "success": False,
            "error": "Publicación no encontrada",
            "id_publicacion": id_publicacion,
        }), 404

    return jsonify({
        "success": True,
        "data": item,
    }), 200
