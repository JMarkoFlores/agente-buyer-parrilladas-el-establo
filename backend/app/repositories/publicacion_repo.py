"""
Repositorio para la entidad Publicacion.
"""
from app.extensions import db
from app.models.marketing import Publicacion
from app.services.data_filter_service import DataFilterService


class PublicacionRepository:
    @staticmethod
    def get_all(
        id_plataforma: int | None = None,
        id_campana: int | None = None,
        estado: str | None = None,
        include_demo: bool = False,
    ) -> list[Publicacion]:
        query = db.session.query(Publicacion)
        if not include_demo:
            query = DataFilterService.apply_real_publicacion_filter(query)

        if id_plataforma is not None:
            query = query.filter(Publicacion.id_plataforma == id_plataforma)
        if id_campana is not None:
            query = query.filter(Publicacion.id_campana == id_campana)
        if estado:
            query = query.filter(Publicacion.estado == estado.upper())
        return query.order_by(Publicacion.fecha_publicacion.desc()).all()

    @staticmethod
    def get_by_id(id_publicacion: int) -> Publicacion | None:
        return db.session.query(Publicacion).filter(Publicacion.id_publicacion == id_publicacion).first()
