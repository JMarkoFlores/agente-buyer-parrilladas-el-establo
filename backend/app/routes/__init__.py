"""
Módulo de rutas y Blueprints del sistema Agente BUYER.
"""
from app.routes.health import health_bp
from app.routes.db_status import db_status_bp
from app.routes.plataformas import plataformas_bp
from app.routes.productos import productos_bp
from app.routes.campanas import campanas_bp
from app.routes.publicaciones import publicaciones_bp
from app.routes.buyers import buyers_bp
from app.routes.estadisticas import estadisticas_bp
from app.routes.facebook_routes import facebook_bp
from app.routes.instagram_routes import instagram_bp

__all__ = [
    "health_bp",
    "db_status_bp",
    "plataformas_bp",
    "productos_bp",
    "campanas_bp",
    "publicaciones_bp",
    "buyers_bp",
    "estadisticas_bp",
    "facebook_bp",
    "instagram_bp",
]
