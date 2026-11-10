"""
Repositorio para la entidad ProductoCarta.
"""
from app.extensions import db
from app.models.catalogo import ProductoCarta


class ProductoRepository:
    @staticmethod
    def get_all(categoria: str | None = None, activo: bool | None = None) -> list[ProductoCarta]:
        query = db.session.query(ProductoCarta)
        if categoria:
            query = query.filter(ProductoCarta.categoria == categoria.upper())
        if activo is not None:
            query = query.filter(ProductoCarta.activo == activo)
        return query.order_by(ProductoCarta.categoria, ProductoCarta.nombre).all()

    @staticmethod
    def get_by_id(id_producto: int) -> ProductoCarta | None:
        return db.session.query(ProductoCarta).filter(ProductoCarta.id_producto == id_producto).first()
