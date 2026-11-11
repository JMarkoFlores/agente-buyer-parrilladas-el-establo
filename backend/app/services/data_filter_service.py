"""
Servicio centralizado de política y filtrado de datos reales vs DEMO.
Asegura que ninguna consulta operativa del frontend mezcle registros de demostración
con los datos reales capturados desde Meta Graph API (Facebook e Instagram).

Garantiza:
- Exclusión total de registros DEMO en consultas operativas.
- Preservación íntegra de registros DEMO en SQL Server (sin DELETE, DROP ni TRUNCATE).
- Uso del corte diario más reciente para métricas acumuladas (sin sumar históricos).
- Diferenciación estricta entre NULL (no disponible) y 0 (valor cero confirmado).
- Distinción entre comentarios capturados en DB y comentarios reportados por Meta.
"""
from __future__ import annotations

import logging
from typing import Any
from sqlalchemy import func, and_, or_, not_

from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Publicacion, MetricaPublicacionDiaria
from app.models.persona import Buyer, InteraccionPublicacion
from app.models.auditoria import AccionAgente, EventoIntegracion

logger = logging.getLogger("data_filter_service")

# Identificadores primarios de registros DEMO insertados en dbo.02_LLENAR_BUYER_FINAL.sql
DEMO_PUBLICACION_IDS = (1, 2, 3)
DEMO_INTERACCION_IDS = (1, 2, 3, 4)
DEMO_METRICA_IDS = (1, 2, 3, 4)
DEMO_BUYER_IDS = (1, 2, 3, 4, 5)
DEMO_PERSONA_IDS = (1, 2, 3, 4)
DEMO_ACCION_AGENTE_IDS = (1, 2, 3)


class DataFilterService:
    """
    Política centralizada de discriminación y filtrado de datos reales.
    """

    # -------------------------------------------------------------------------
    # Predicados en memoria
    # -------------------------------------------------------------------------

    @staticmethod
    def is_demo_post(meta_post_id: str | None, id_publicacion: int | None = None) -> bool:
        """Determina si una publicación corresponde a un registro DEMO."""
        if id_publicacion is not None and id_publicacion in DEMO_PUBLICACION_IDS:
            return True
        if not meta_post_id:
            return False
        return meta_post_id.upper().startswith("DEMO_")

    @staticmethod
    def is_demo_interaction(id_interaccion_ext: str | None, id_interaccion: int | None = None) -> bool:
        """Determina si un comentario/interacción corresponde a un registro DEMO."""
        if id_interaccion is not None and id_interaccion in DEMO_INTERACCION_IDS:
            return True
        if not id_interaccion_ext:
            return False
        return id_interaccion_ext.upper().startswith("DEMO_")

    @staticmethod
    def is_demo_buyer(referencia_externa: str | None, id_buyer: int | None = None) -> bool:
        """
        Determina si un prospecto BUYER es sintético / DEMO.
        Excluye prefijos DEMO_, COOKIE_ y los sintéticos de WhatsApp generados en el llenado inicial.
        """
        if id_buyer is not None and id_buyer in DEMO_BUYER_IDS:
            return True
        if not referencia_externa:
            return False
        ref_upper = referencia_externa.strip().upper()
        if (
            ref_upper.startswith("DEMO_")
            or ref_upper.startswith("COOKIE_")
            or ref_upper.startswith("WHATSAPP_5199900000")
        ):
            return True
        return False

    @staticmethod
    def is_demo_action(id_accion: int | None, nombre_agente: str | None = None) -> bool:
        """Determina si una acción de agente es del llenado sintético inicial."""
        if id_accion is not None and id_accion in DEMO_ACCION_AGENTE_IDS:
            return True
        return False

    # -------------------------------------------------------------------------
    # Filtros SQLAlchemy para consultas
    # -------------------------------------------------------------------------

    @classmethod
    def apply_real_publicacion_filter(cls, query):
        """Aplica filtros SQLAlchemy para publicaciones reales."""
        return query.filter(
            ~Publicacion.meta_post_id.like("DEMO_%"),
            ~Publicacion.id_publicacion.in_(DEMO_PUBLICACION_IDS),
        )

    @classmethod
    def apply_real_interaccion_filter(cls, query):
        """Aplica filtros SQLAlchemy para comentarios reales."""
        return query.filter(
            ~InteraccionPublicacion.id_interaccion_externa.like("DEMO_%"),
            ~InteraccionPublicacion.id_interaccion.in_(DEMO_INTERACCION_IDS),
        )

    @classmethod
    def apply_real_buyer_filter(cls, query):
        """
        Aplica filtros SQLAlchemy para prospectos BUYER reales comprobados.
        Solo prospectos captados desde interacciones reales de Meta.
        """
        return query.filter(
            ~Buyer.id_buyer.in_(DEMO_BUYER_IDS),
            ~Buyer.referencia_externa.like("DEMO_%"),
            ~Buyer.referencia_externa.like("COOKIE_%"),
            ~Buyer.referencia_externa.like("WHATSAPP_%"),
            or_(
                Buyer.id_persona.is_(None),
                ~Buyer.id_persona.in_(DEMO_PERSONA_IDS),
            ),
        )

    @classmethod
    def apply_real_accion_filter(cls, query):
        """Aplica filtros SQLAlchemy para historial operativo y auditoría real."""
        return query.filter(
            ~AccionAgente.id_accion.in_(DEMO_ACCION_AGENTE_IDS),
            AccionAgente.id_sesion_whatsapp.is_(None),
            or_(
                AccionAgente.id_buyer.is_(None),
                ~AccionAgente.id_buyer.in_(DEMO_BUYER_IDS),
            ),
        )

    # -------------------------------------------------------------------------
    # Consultas compuestas con métricas acumuladas (último corte válido)
    # -------------------------------------------------------------------------

    @classmethod
    def get_real_publicaciones_con_metricas(
        cls,
        id_plataforma: int | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> tuple[list[dict[str, Any]], int]:
        """
        Obtiene publicaciones REALES combinando:
        - Metadatos de la publicación (dbo.publicacion).
        - Último corte de métricas diarias (dbo.metrica_publicacion_diaria).
        - Cantidad de comentarios individuales capturados (dbo.interaccion_publicacion).
        
        Garantiza que:
        - No se suman múltiples filas históricas para los contadores acumulados actuales.
        - Se respeta NULL vs 0.
        - No aparecen registros DEMO.
        """
        # Subconsulta para el último corte de fecha por publicación
        subq_max_corte = (
            db.session.query(
                MetricaPublicacionDiaria.id_publicacion,
                func.max(MetricaPublicacionDiaria.fecha_corte).label("max_corte"),
            )
            .group_by(MetricaPublicacionDiaria.id_publicacion)
            .subquery()
        )

        # Subconsulta para comentarios capturados en BD
        subq_comentarios = (
            db.session.query(
                InteraccionPublicacion.id_publicacion,
                func.count(InteraccionPublicacion.id_interaccion).label("capturados"),
            )
            .filter(~InteraccionPublicacion.id_interaccion_externa.like("DEMO_%"))
            .filter(~InteraccionPublicacion.id_interaccion.in_(DEMO_INTERACCION_IDS))
            .group_by(InteraccionPublicacion.id_publicacion)
            .subquery()
        )

        query = (
            db.session.query(
                Publicacion,
                MetricaPublicacionDiaria.total_reacciones,
                MetricaPublicacionDiaria.total_comentarios,
                MetricaPublicacionDiaria.total_compartidos,
                MetricaPublicacionDiaria.alcance,
                MetricaPublicacionDiaria.impresiones,
                MetricaPublicacionDiaria.fecha_corte,
                MetricaPublicacionDiaria.fecha_obtencion,
                func.coalesce(subq_comentarios.c.capturados, 0).label("comentarios_capturados"),
            )
            .outerjoin(
                subq_max_corte,
                Publicacion.id_publicacion == subq_max_corte.c.id_publicacion,
            )
            .outerjoin(
                MetricaPublicacionDiaria,
                and_(
                    Publicacion.id_publicacion == MetricaPublicacionDiaria.id_publicacion,
                    MetricaPublicacionDiaria.fecha_corte == subq_max_corte.c.max_corte,
                ),
            )
            .outerjoin(
                subq_comentarios,
                Publicacion.id_publicacion == subq_comentarios.c.id_publicacion,
            )
            .filter(
                ~Publicacion.meta_post_id.like("DEMO_%"),
                ~Publicacion.id_publicacion.in_(DEMO_PUBLICACION_IDS),
            )
        )

        if id_plataforma is not None:
            query = query.filter(Publicacion.id_plataforma == id_plataforma)

        total = query.count()
        rows = (
            query.order_by(Publicacion.fecha_publicacion.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

        items: list[dict[str, Any]] = []
        for r in rows:
            pub = r[0]
            total_reacciones = r[1]
            total_comentarios = r[2]
            total_compartidos = r[3]
            alcance = r[4]
            impresiones = r[5]
            fecha_corte = r[6]
            fecha_obtencion = r[7]
            comentarios_capturados = int(r[8] or 0)

            plat_code = pub.plataforma.codigo if pub.plataforma else "DESCONOCIDA"

            item: dict[str, Any] = {
                "id_publicacion": pub.id_publicacion,
                "id_plataforma": pub.id_plataforma,
                "plataforma_codigo": plat_code,
                "id_campana": pub.id_campana,
                "campana_nombre": pub.campana.nombre if pub.campana else None,
                "meta_post_id": pub.meta_post_id,
                "texto": pub.texto,
                "url_publicacion": pub.url_publicacion,
                "url_formulario": pub.url_formulario,
                "fecha_publicacion": pub.fecha_publicacion.isoformat() if pub.fecha_publicacion else None,
                "estado": pub.estado,
                "origen": "META_REAL",
                # Métricas agregadas de Meta (manteniendo NULL vs 0)
                "total_reacciones": total_reacciones,
                "total_likes": total_reacciones,  # Alias común para Instagram
                "total_comentarios": total_comentarios,
                "comentarios_reportados_meta": total_comentarios,
                "comentarios_capturados": comentarios_capturados,
                "total_compartidos": total_compartidos,
                "alcance": alcance,
                "impresiones": impresiones,
                "fecha_corte_metrica": fecha_corte.isoformat() if fecha_corte else None,
                "ultima_sincronizacion": fecha_obtencion.isoformat() if fecha_obtencion else None,
            }
            items.append(item)

        return items, total
