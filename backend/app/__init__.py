"""
Fábrica de aplicaciones (Application Factory) para el Agente BUYER - Parrilladas El Establo.
"""
import logging
from flask import Flask, jsonify
from app.config import get_config, BaseConfig
from app.extensions import db, cors


def create_app(config_class: type[BaseConfig] | BaseConfig | None = None) -> Flask:
    """
    Crea y configura la aplicación Flask utilizando el patrón Application Factory.
    """
    application = Flask(__name__)

    # 1. Cargar configuración
    if config_class is None:
        cfg = get_config()
        application.config.from_object(cfg)
    elif isinstance(config_class, type):
        application.config.from_object(config_class())
    else:
        application.config.from_object(config_class)

    # 2. Configurar Logging
    logging.basicConfig(
        level=logging.INFO if not application.debug else logging.DEBUG,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )
    logger = logging.getLogger(__name__)
    logger.info("Iniciando aplicación Agente BUYER en modo %s", application.config.get("ENV", "production"))

    # 3. Inicializar extensiones
    allowed_origins = application.config.get("CORS_ORIGINS", ["http://localhost:3000"])
    cors.init_app(application, resources={r"/api/*": {"origins": allowed_origins}})

    # Inicializar Base de Datos SQLAlchemy
    db.init_app(application)

    # 4. Importar modelos para registro en SQLAlchemy (sin llamar a db.create_all())
    with application.app_context():
        import app.models  # noqa: F401

    # 5. Registrar Blueprints
    from app.routes import (
        health_bp,
        db_status_bp,
        plataformas_bp,
        productos_bp,
        campanas_bp,
        publicaciones_bp,
        buyers_bp,
        estadisticas_bp,
        facebook_bp,
    )

    application.register_blueprint(health_bp, url_prefix="/api")
    application.register_blueprint(db_status_bp, url_prefix="/api")
    application.register_blueprint(plataformas_bp, url_prefix="/api")
    application.register_blueprint(productos_bp, url_prefix="/api")
    application.register_blueprint(campanas_bp, url_prefix="/api")
    application.register_blueprint(publicaciones_bp, url_prefix="/api")
    application.register_blueprint(buyers_bp, url_prefix="/api")
    application.register_blueprint(estadisticas_bp, url_prefix="/api")
    application.register_blueprint(facebook_bp, url_prefix="/api/facebook")

    # 6. Manejadores globales de errores JSON
    @application.errorhandler(404)
    def handle_not_found(e):
        return jsonify({
            "success": False,
            "error": "Recurso no encontrado",
            "message": str(e),
        }), 404

    @application.errorhandler(400)
    def handle_bad_request(e):
        return jsonify({
            "success": False,
            "error": "Solicitud incorrecta",
            "message": str(e),
        }), 400

    @application.errorhandler(500)
    def handle_internal_server_error(e):
        logger.error("Error interno del servidor: %s", str(e))
        return jsonify({
            "success": False,
            "error": "Error interno del servidor",
            "message": "Ocurrió un error inesperado al procesar la solicitud.",
        }), 500

    return application
