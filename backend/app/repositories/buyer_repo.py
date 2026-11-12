"""
Repositorio para la entidad Buyer y Prospectos.
"""
from app.extensions import db
from app.models.persona import Buyer, InteraccionPublicacion
from app.services.data_filter_service import DataFilterService


class BuyerRepository:
    @staticmethod
    def get_all(
        estado: str | None = None,
        id_plataforma: int | None = None,
        limit: int = 50,
        offset: int = 0,
        include_demo: bool = False,
    ) -> tuple[list[Buyer], int]:
        query = db.session.query(Buyer)
        if not include_demo:
            query = DataFilterService.apply_real_buyer_filter(query)

        if estado:
            query = query.filter(Buyer.estado == estado.upper())
        if id_plataforma is not None:
            query = query.filter(Buyer.id_plataforma_origen == id_plataforma)

        total = query.count()
        results = (
            query.order_by(Buyer.fecha_primer_contacto.desc(), Buyer.id_buyer.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )
        return results, total

    @staticmethod
    def get_by_id(id_buyer: int) -> Buyer | None:
        return db.session.query(Buyer).filter(Buyer.id_buyer == id_buyer).first()

    @staticmethod
    def get_nombre_publico(id_buyer: int) -> str | None:
        """
        Nombre público más reciente expuesto por Meta para las interacciones del BUYER.
        Meta omite el nombre de algunos autores; en ese caso retorna None.
        """
        row = (
            db.session.query(InteraccionPublicacion.nombre_visible)
            .filter(
                InteraccionPublicacion.id_buyer == id_buyer,
                InteraccionPublicacion.nombre_visible.isnot(None),
                InteraccionPublicacion.nombre_visible != "",
            )
            .order_by(InteraccionPublicacion.fecha_interaccion.desc())
            .first()
        )
        return row[0] if row else None

    @staticmethod
    def get_ultimas_interacciones(id_buyer: int, limit: int = 5) -> list[InteraccionPublicacion]:
        query = db.session.query(InteraccionPublicacion).filter(
            InteraccionPublicacion.id_buyer == id_buyer
        )
        query = DataFilterService.apply_real_interaccion_filter(query)
        return (
            query.order_by(InteraccionPublicacion.fecha_interaccion.desc())
            .limit(limit)
            .all()
        )
