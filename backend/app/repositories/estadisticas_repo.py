"""
Repositorio para agregaciones y métricas analíticas del Agente BUYER.
"""
from typing import Any
from sqlalchemy import func
from app.extensions import db
from app.models.catalogo import Plataforma, ProductoCarta
from app.models.marketing import Campana, Publicacion, GastoAnuncioDiario
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.web import VisitaWeb, VisitanteWeb
from app.models.whatsapp import SesionWhatsapp


class EstadisticasRepository:
    @staticmethod
    def get_resumen_general() -> dict[str, Any]:
        # Conteo de BUYERS
        total_buyers = db.session.query(func.count(Buyer.id_buyer)).scalar() or 0
        buyers_convertidos = (
            db.session.query(func.count(Buyer.id_buyer))
            .filter(Buyer.estado == "CONVERTIDO_LEAD")
            .scalar()
            or 0
        )
        buyers_en_proceso = (
            db.session.query(func.count(Buyer.id_buyer))
            .filter(Buyer.estado == "BUYER")
            .scalar()
            or 0
        )
        tasa_conversion = round((buyers_convertidos / total_buyers * 100), 2) if total_buyers > 0 else 0.0

        # Conteo de Marketing
        campanas_activas = (
            db.session.query(func.count(Campana.id_campana))
            .filter(Campana.activa == True)
            .scalar()
            or 0
        )
        total_publicaciones = db.session.query(func.count(Publicacion.id_publicacion)).scalar() or 0
        productos_activos = (
            db.session.query(func.count(ProductoCarta.id_producto))
            .filter(ProductoCarta.activo == True)
            .scalar()
            or 0
        )

        # Interacciones por canal
        total_interacciones = db.session.query(func.count(InteraccionPublicacion.id_interaccion)).scalar() or 0
        total_sesiones_wa = db.session.query(func.count(SesionWhatsapp.id_sesion)).scalar() or 0
        total_visitas_web = db.session.query(func.count(VisitaWeb.id_visita)).scalar() or 0
        total_visitantes_web = db.session.query(func.count(VisitanteWeb.id_visitante)).scalar() or 0

        # Gasto publicitario total
        gasto_total = db.session.query(func.sum(GastoAnuncioDiario.monto)).scalar()
        gasto_total_float = round(float(gasto_total), 2) if gasto_total is not None else 0.0

        # Desglose de BUYER por plataforma
        desglose_raw = (
            db.session.query(Plataforma.codigo, func.count(Buyer.id_buyer))
            .join(Buyer, Plataforma.id_plataforma == Buyer.id_plataforma_origen)
            .group_by(Plataforma.codigo)
            .all()
        )
        buyers_por_plataforma = {codigo: count for codigo, count in desglose_raw}

        return {
            "embudo_buyer": {
                "total_buyers": total_buyers,
                "buyers_en_proceso": buyers_en_proceso,
                "buyers_convertidos_lead": buyers_convertidos,
                "tasa_conversion_lead_porcentaje": tasa_conversion,
            },
            "marketing": {
                "campanas_activas": campanas_activas,
                "total_publicaciones": total_publicaciones,
                "productos_carta_activos": productos_activos,
                "gasto_publicitario_total_pen": gasto_total_float,
            },
            "canales_interaccion": {
                "interacciones_redes_sociales": total_interacciones,
                "sesiones_whatsapp": total_sesiones_wa,
                "visitas_landing_page": total_visitas_web,
                "visitantes_unicos_web": total_visitantes_web,
            },
            "buyers_por_plataforma": buyers_por_plataforma,
        }
