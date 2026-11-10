"""
Repositorio para la entidad Campana.
"""
from app.extensions import db
from app.models.marketing import Campana


class CampanaRepository:
    @staticmethod
    def get_all(activa: bool | None = None, id_plataforma: int | None = None) -> list[Campana]:
        query = db.session.query(Campana)
        if activa is not None:
            query = query.filter(Campana.activa == activa)
        if id_plataforma is not None:
            query = query.filter(Campana.id_plataforma == id_plataforma)
        return query.order_by(Campana.fecha_inicio.desc(), Campana.id_campana.desc()).all()

    @staticmethod
    def get_by_id(id_campana: int) -> Campana | None:
        return db.session.query(Campana).filter(Campana.id_campana == id_campana).first()
