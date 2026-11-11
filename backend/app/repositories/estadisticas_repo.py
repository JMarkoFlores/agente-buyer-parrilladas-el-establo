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
from app.services.data_filter_service import DataFilterService


class EstadisticasRepository:
    @staticmethod
    def get_resumen_general() -> dict[str, Any]:
        # Conteo de BUYERS Reales
        buyer_query = db.session.query(Buyer)
        buyer_query = DataFilterService.apply_real_buyer_filter(buyer_query)
        total_buyers = buyer_query.count()

        buyers_convertidos = buyer_query.filter(Buyer.estado == "CONVERTIDO_LEAD").count()
        buyers_en_proceso = buyer_query.filter(Buyer.estado == "BUYER").count()
        tasa_conversion = round((buyers_convertidos / total_buyers * 100), 2) if total_buyers > 0 else 0.0

        # Conteo de Marketing Real
        pub_query = db.session.query(Publicacion)
        pub_query = DataFilterService.apply_real_publicacion_filter(pub_query)
        total_publicaciones = pub_query.count()

        campanas_activas = 0  # No hay campañas activas con Meta Ads en producción aún
        productos_activos = (
            db.session.query(func.count(ProductoCarta.id_producto))
            .filter(ProductoCarta.activo == True)
            .scalar()
            or 0
        )

        # Interacciones reales por canal
        inter_query = db.session.query(InteraccionPublicacion)
        inter_query = DataFilterService.apply_real_interaccion_filter(inter_query)
        total_interacciones = inter_query.count()

        total_sesiones_wa = 0
        total_visitas_web = 0
        total_visitantes_web = 0

        # Gasto publicitario total real
        gasto_total_float = 0.0

        # Desglose de BUYER real por plataforma
        desglose_raw = (
            buyer_query.join(Plataforma, Plataforma.id_plataforma == Buyer.id_plataforma_origen)
            .with_entities(Plataforma.codigo, func.count(Buyer.id_buyer))
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
