"""
Módulo de repositorios para acceso a datos.
"""
from app.repositories.plataforma_repo import PlataformaRepository
from app.repositories.producto_repo import ProductoRepository
from app.repositories.campana_repo import CampanaRepository
from app.repositories.publicacion_repo import PublicacionRepository
from app.repositories.buyer_repo import BuyerRepository
from app.repositories.estadisticas_repo import EstadisticasRepository
from app.repositories.facebook_repository import FacebookRepository

__all__ = [
    "PlataformaRepository",
    "ProductoRepository",
    "CampanaRepository",
    "PublicacionRepository",
    "BuyerRepository",
    "EstadisticasRepository",
    "FacebookRepository",
]
