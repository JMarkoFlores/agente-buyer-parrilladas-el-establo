"""
Configuración de fixtures para pytest.
"""
import sys
from pathlib import Path
import pytest

# Asegurar que el directorio backend está en el sys.path
backend_dir = Path(__file__).resolve().parent.parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from app import create_app
from app.config import TestingConfig


@pytest.fixture(scope="session")
def app():
    """Instancia de la aplicación Flask configurada para pruebas."""
    application = create_app(TestingConfig)
    return application


@pytest.fixture(scope="session")
def client(app):
    """Cliente de pruebas HTTP para ejecutar peticiones a los endpoints."""
    return app.test_client()
