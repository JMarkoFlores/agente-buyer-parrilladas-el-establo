"""
Blueprint de comprobación de salud de la aplicación Flask.
GET /api/health
"""
from datetime import datetime, timezone
from flask import Blueprint, jsonify

health_bp = Blueprint("health", __name__)


@health_bp.route("/health", methods=["GET"])
def health_check():
    """
    Comprueba que el backend Flask se encuentra en ejecución.
    """
    return jsonify({
        "status": "healthy",
        "service": "Agente Inteligente BUYER — Parrilladas El Establo",
        "version": "1.0.0",
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "stage": "Etapa 1: Backend Flask y Conexion SQL Server",
    }), 200
