"""
Blueprint para métricas y estadísticas ejecutivas del sistema BUYER.
GET /api/estadisticas/resumen
"""
from flask import Blueprint, jsonify
from app.services.stats_service import StatsService

estadisticas_bp = Blueprint("estadisticas", __name__)
service = StatsService()


@estadisticas_bp.route("/estadisticas/resumen", methods=["GET"])
def get_resumen_estadisticas():
    """
    Retorna el resumen analítico general de captación y embudo de conversión para Parrilladas El Establo.
    """
    data = service.get_resumen()
    return jsonify({
        "success": True,
        "data": data,
    }), 200
