"""
Repositorio para la entidad Plataforma.
"""
from app.extensions import db
from app.models.catalogo import Plataforma


class PlataformaRepository:
    @staticmethod
    def get_all(activa: bool | None = None) -> list[Plataforma]:
        query = db.session.query(Plataforma)
        if activa is not None:
            query = query.filter(Plataforma.activa == activa)
        return query.order_by(Plataforma.id_plataforma).all()

    @staticmethod
    def get_by_id(id_plataforma: int) -> Plataforma | None:
        return db.session.query(Plataforma).filter(Plataforma.id_plataforma == id_plataforma).first()

    @staticmethod
    def get_by_codigo(codigo: str) -> Plataforma | None:
        return db.session.query(Plataforma).filter(Plataforma.codigo == codigo.upper()).first()
