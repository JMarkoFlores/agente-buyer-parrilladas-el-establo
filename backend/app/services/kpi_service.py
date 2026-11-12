"""
Servicio centralizado de Inteligencia de Negocios y Métricas KPI:
- Fuente única de verdad sobre Microsoft SQL Server (base buyer).
- Cálculo de métricas de Landing Page y Carta Digital.
- Cálculo de los tres KPI estratégicos:
  1. CPA: Costo por Anuncio / Lead (KPI MIXTO: gasto simulado / conversiones reales)
  2. TMD: Tasa de Interés en Menú Digital (KPI REAL: visitantes carta / visitantes landing)
  3. B1: Tasa de Conversión BUYER a LEAD (KPI REAL: buyers convertidos / buyers totales)
- Integración comercial multicanal: Facebook, Instagram y Landing Page.
- Política de fechas homogénea (UTC para base de datos, America/Lima UTC-5 para filtros).
"""
from __future__ import annotations

import logging
from datetime import datetime, date, timedelta
from typing import Any
from sqlalchemy import func, distinct, and_, or_, desc

from app.extensions import db
from app.models.catalogo import Plataforma
from app.models.marketing import Campana, Publicacion, Anuncio, GastoAnuncioDiario
from app.models.persona import Persona, Buyer, InteraccionPublicacion
from app.models.web import VisitanteWeb, VisitaWeb, EventoWeb
from app.models.conversion import FormularioCaptacion, LeadConversion, HistorialFases
from app.services.data_filter_service import (
    DataFilterService,
    DEMO_BUYER_IDS,
    DEMO_PERSONA_IDS,
    DEMO_PUBLICACION_IDS,
    DEMO_INTERACCION_IDS,
)

logger = logging.getLogger("kpi_service")


class KpiService:
    """
    Servicio unificado de cálculo de KPI y analítica multicanal.
    """

    # -------------------------------------------------------------------------
    # Política Temporal Centralizada
    # -------------------------------------------------------------------------
    @staticmethod
    def parse_date_range(
        periodo: str | None = None,
        f_inicio_str: str | None = None,
        f_fin_str: str | None = None,
    ) -> tuple[datetime | None, datetime | None, str]:
        """
        Calcula las cotas UTC para filtrado en SQL Server y la etiqueta representativa en America/Lima.
        """
        periodo = (periodo or "").strip().lower()
        ahora_utc = datetime.utcnow()
        ahora_lima = ahora_utc - timedelta(hours=5)

        f_inicio: datetime | None = None
        f_fin: datetime | None = None
        periodo_label = "Todo el histórico"

        if periodo == "hoy":
            inicio_lima = datetime(ahora_lima.year, ahora_lima.month, ahora_lima.day, 0, 0, 0)
            f_inicio = inicio_lima + timedelta(hours=5)
            f_fin = f_inicio + timedelta(days=1) - timedelta(microseconds=1)
            periodo_label = "Hoy"
        elif periodo in ("7dias", "7_dias", "7d"):
            f_inicio = ahora_utc - timedelta(days=7)
            f_fin = ahora_utc
            periodo_label = "Últimos 7 días"
        elif periodo in ("30dias", "30_dias", "30d"):
            f_inicio = ahora_utc - timedelta(days=30)
            f_fin = ahora_utc
            periodo_label = "Últimos 30 días"
        elif f_inicio_str or f_fin_str:
            if f_inicio_str:
                try:
                    f_inicio = datetime.strptime(f_inicio_str[:10], "%Y-%m-%d")
                except ValueError:
                    pass
            if f_fin_str:
                try:
                    f_fin = datetime.strptime(f_fin_str[:10] + " 23:59:59", "%Y-%m-%d %H:%M:%S")
                except ValueError:
                    pass
            if f_inicio and f_fin:
                if f_inicio_str and f_fin_str and f_inicio_str[:10] == f_fin_str[:10]:
                    periodo_label = f"Fecha: {f_inicio_str[:10]}"
                else:
                    periodo_label = f"{f_inicio_str[:10]} al {f_fin_str[:10]}"
            elif f_inicio and f_inicio_str:
                periodo_label = f"Desde {f_inicio_str[:10]}"
            elif f_fin and f_fin_str:
                periodo_label = f"Hasta {f_fin_str[:10]}"

        return f_inicio, f_fin, periodo_label

    # -------------------------------------------------------------------------
    # Indicadores de Landing Page y Carta Digital
    # -------------------------------------------------------------------------
    @classmethod
    def get_landing_metrics(
        cls,
        f_inicio: datetime | None = None,
        f_fin: datetime | None = None,
        periodo_label: str = "Todo el histórico",
    ) -> dict[str, Any]:
        """
        Retorna los 7 indicadores de Landing Page consultando directamente SQL Server.
        Usado tanto por /api/landing/estadisticas como por /api/dashboard/resumen.
        """
        # 1. Visitas Landing (sesiones)
        q_visitas = VisitaWeb.query
        if f_inicio:
            q_visitas = q_visitas.filter(VisitaWeb.fecha_inicio >= f_inicio)
        if f_fin:
            q_visitas = q_visitas.filter(VisitaWeb.fecha_inicio <= f_fin)
        visitas_landing = q_visitas.count()

        # 2. Visitantes Landing (navegadores únicos aproximados)
        visitantes_landing = (
            q_visitas.with_entities(func.count(distinct(VisitaWeb.id_visitante))).scalar() or 0
        )

        # 3. Visualizaciones Carta (eventos VISTA_CARTA)
        q_vc = EventoWeb.query.filter(EventoWeb.tipo == "VISTA_CARTA")
        if f_inicio:
            q_vc = q_vc.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_vc = q_vc.filter(EventoWeb.fecha_evento <= f_fin)
        visualizaciones_carta = q_vc.count()

        # 4. Visitantes Carta (navegadores únicos que abrieron /carta/)
        q_vc_vis = (
            db.session.query(func.count(distinct(VisitaWeb.id_visitante)))
            .join(EventoWeb, VisitaWeb.id_visita == EventoWeb.id_visita)
            .filter(EventoWeb.tipo == "VISTA_CARTA")
        )
        if f_inicio:
            q_vc_vis = q_vc_vis.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_vc_vis = q_vc_vis.filter(EventoWeb.fecha_evento <= f_fin)
        visitantes_carta = q_vc_vis.scalar() or 0

        # Clics hacia la carta (evento CLIC_CARTA / VER_MENU)
        q_clics = EventoWeb.query.filter(EventoWeb.tipo.in_(["CLIC_CARTA", "VER_MENU"]))
        if f_inicio:
            q_clics = q_clics.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_clics = q_clics.filter(EventoWeb.fecha_evento <= f_fin)
        clics_carta = q_clics.count()

        # 5. Formularios exitosos (plataforma 3 = LANDING_PAGE)
        q_forms = FormularioCaptacion.query.filter_by(id_plataforma_origen=3)
        if f_inicio:
            q_forms = q_forms.filter(FormularioCaptacion.fecha_envio >= f_inicio)
        if f_fin:
            q_forms = q_forms.filter(FormularioCaptacion.fecha_envio <= f_fin)
        formularios = q_forms.count()

        # 6. LEADS únicos convertidos (distinct persona)
        q_leads = (
            db.session.query(func.count(distinct(LeadConversion.id_persona)))
            .join(FormularioCaptacion, LeadConversion.id_formulario == FormularioCaptacion.id_formulario)
            .filter(FormularioCaptacion.id_plataforma_origen == 3)
        )
        if f_inicio:
            q_leads = q_leads.filter(LeadConversion.fecha_conversion >= f_inicio)
        if f_fin:
            q_leads = q_leads.filter(LeadConversion.fecha_conversion <= f_fin)
        leads = q_leads.scalar() or 0

        # 7. Tasa de conversión de la Landing Page (%)
        conversion = round((leads / visitantes_landing * 100), 2) if visitantes_landing > 0 else 0.0

        # Serie diaria de visitas para gráfico (exclusivamente datos reales transaccionales)
        q_dias = (
            db.session.query(
                func.cast(VisitaWeb.fecha_inicio, db.Date).label("fecha"),
                func.count(VisitaWeb.id_visita).label("visitas"),
                func.count(distinct(VisitaWeb.id_visitante)).label("visitantes"),
            )
        )
        if f_inicio:
            q_dias = q_dias.filter(VisitaWeb.fecha_inicio >= f_inicio)
        if f_fin:
            q_dias = q_dias.filter(VisitaWeb.fecha_inicio <= f_fin)

        filas_dias = (
            q_dias.group_by(func.cast(VisitaWeb.fecha_inicio, db.Date))
            .order_by(func.cast(VisitaWeb.fecha_inicio, db.Date).asc())
            .all()
        )

        # Visualizaciones de carta agrupadas por día para el mismo período
        q_vc_dias = (
            db.session.query(
                func.cast(EventoWeb.fecha_evento, db.Date).label("fecha"),
                func.count(EventoWeb.id_evento).label("visualizaciones_carta"),
            )
            .filter(EventoWeb.tipo == "VISTA_CARTA")
        )
        if f_inicio:
            q_vc_dias = q_vc_dias.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_vc_dias = q_vc_dias.filter(EventoWeb.fecha_evento <= f_fin)

        map_vc_dias = {
            r.fecha.strftime("%Y-%m-%d"): r.visualizaciones_carta
            for r in q_vc_dias.group_by(func.cast(EventoWeb.fecha_evento, db.Date)).all()
            if r.fecha
        }

        visitas_por_dia = [
            {
                "fecha": f.fecha.strftime("%Y-%m-%d") if f.fecha else "",
                "visitas": f.visitas,
                "visitantes": f.visitantes,
                "visualizaciones_carta": map_vc_dias.get(f.fecha.strftime("%Y-%m-%d") if f.fecha else "", 0),
            }
            for f in filas_dias
        ]

        return {
            "visitas_landing": visitas_landing,
            "visitantes_landing": visitantes_landing,
            "visualizaciones_carta": visualizaciones_carta,
            "visitantes_carta": visitantes_carta,
            "formularios": formularios,
            "leads": leads,
            "conversion": conversion,
            "clics_carta": clics_carta,
            "periodo": periodo_label,
            "visitas_por_dia": visitas_por_dia,
        }

    # -------------------------------------------------------------------------
    # Integración Multicanal de BUYERS (Facebook, Instagram, Landing Page)
    # -------------------------------------------------------------------------
    @classmethod
    def get_multichannel_buyers_summary(cls) -> dict[str, Any]:
        """
        Retorna la reconciliación de BUYERS multicanal:
        - Facebook: captados por comentarios en posts de Facebook
        - Instagram: captados por comentarios en media de Instagram
        - Landing Page: prospectos web identificados convertidos a LEAD
        - Total: suma consolidada de prospectos únicos sin duplicación arbitraria
        """
        # Consultar BUYERS reales excluyendo sintéticos demo
        buyer_query = db.session.query(Buyer)
        buyer_query = DataFilterService.apply_real_buyer_filter(buyer_query)
        buyers_reales = buyer_query.all()

        fb_buyers = [b for b in buyers_reales if b.id_plataforma_origen == 1]
        ig_buyers = [b for b in buyers_reales if b.id_plataforma_origen == 2]
        landing_buyers = [b for b in buyers_reales if b.id_plataforma_origen == 3]

        # Contar personas únicas para landing (evita contar dos veces a quien envió 2 formularios)
        personas_landing_unicas = len({b.id_persona for b in landing_buyers if b.id_persona})

        # Total convertidos a lead
        convertidos_count = sum(1 for b in buyers_reales if b.estado == "CONVERTIDO_LEAD")
        convertidos_personas_unicas = len({b.id_persona for b in buyers_reales if b.estado == "CONVERTIDO_LEAD" and b.id_persona})

        total_reales = len(fb_buyers) + len(ig_buyers) + len(landing_buyers)

        return {
            "total": total_reales,
            "reales": total_reales,
            "demo": 0,
            "reales_facebook": len(fb_buyers),
            "reales_instagram": len(ig_buyers),
            "reales_landing": len(landing_buyers),
            "personas_landing_unicas": personas_landing_unicas,
            "convertidos_lead_filas": convertidos_count,
            "convertidos_lead_personas": convertidos_personas_unicas,
            "activos": sum(1 for b in buyers_reales if b.estado == "BUYER"),
        }

    # -------------------------------------------------------------------------
    # Los Tres Indicadores Estratégicos (KPIs)
    # -------------------------------------------------------------------------
    @classmethod
    def get_strategic_kpis(
        cls,
        f_inicio: datetime | None = None,
        f_fin: datetime | None = None,
        periodo_label: str = "Todo el histórico",
    ) -> dict[str, Any]:
        """
        Calcula rigurosamente los 3 KPI académicos con trazabilidad completa:
        1. CPA: Costo por Anuncio (MIXTO)
        2. TMD: Tasa de Interés en Menú Digital (REAL)
        3. B1: Tasa de Conversión BUYER a LEAD (REAL)
        """
        # =====================================================================
        # KPI 1 — COSTO POR ANUNCIO (CPA)
        # CPA = Gasto en anuncios / Número de LEADS obtenidos
        # =====================================================================
        q_gasto = db.session.query(func.coalesce(func.sum(GastoAnuncioDiario.monto), 0.0)).filter(
            GastoAnuncioDiario.es_simulado == True
        )
        if f_inicio:
            q_gasto = q_gasto.filter(GastoAnuncioDiario.fecha >= f_inicio.date())
        if f_fin:
            q_gasto = q_gasto.filter(GastoAnuncioDiario.fecha <= f_fin.date())
        gasto_simulado = float(q_gasto.scalar() or 0.0)

        # LEADS reales atribuibles a anuncios dentro del mismo período
        # Se requiere trazabilidad verificable: id_publicacion_origen != NULL
        # o utm_campaign/utm_source ligado a una campaña publicitaria registrada.
        q_leads_ad = (
            db.session.query(LeadConversion.id_persona).distinct()
            .join(FormularioCaptacion, LeadConversion.id_formulario == FormularioCaptacion.id_formulario)
            .outerjoin(VisitaWeb, FormularioCaptacion.id_visita == VisitaWeb.id_visita)
            .filter(
                ~LeadConversion.id_persona.in_(DEMO_PERSONA_IDS),
                or_(
                    FormularioCaptacion.id_publicacion_origen.isnot(None),
                    VisitaWeb.id_publicacion_origen.isnot(None),
                    VisitaWeb.utm_campaign.in_(
                        db.session.query(Campana.meta_campaign_id).filter(Campana.meta_campaign_id.isnot(None))
                    ),
                ),
            )
        )
        if f_inicio:
            q_leads_ad = q_leads_ad.filter(LeadConversion.fecha_conversion >= f_inicio)
        if f_fin:
            q_leads_ad = q_leads_ad.filter(LeadConversion.fecha_conversion <= f_fin)
        leads_atribuibles = len(q_leads_ad.all())

        if leads_atribuibles > 0 and gasto_simulado > 0:
            cpa_valor = round(gasto_simulado / leads_atribuibles, 2)
            cpa_formateado = f"S/ {cpa_valor:.2f}"
            cpa_calculable = True
            cpa_nota = "Cálculo mixto: Gasto simulado académico / Conversiones reales atribuibles"
        else:
            cpa_valor = None
            cpa_formateado = "No calculable — Sin LEADS atribuibles a anuncios"
            cpa_calculable = False
            cpa_nota = (
                "Para este período no existen conversiones con procedencia comprobada desde anuncios pagados. "
                "Conforme al estándar arquitectónico, no se inventan conversiones para forzar un CPA."
            )

        kpi_cpa = {
            "codigo": "CPA",
            "nombre": "Costo por Anuncio (CPA / Costo por LEAD)",
            "formula": "Gasto en anuncios / Número de LEADS obtenidos",
            "valor": cpa_valor,
            "valor_formateado": cpa_formateado,
            "numerador": gasto_simulado,
            "numerador_label": "Gasto en anuncios simulado",
            "denominador": leads_atribuibles,
            "denominador_label": "LEADS reales atribuibles a anuncios",
            "unidad": "S/ por LEAD",
            "periodo": periodo_label,
            "procedencia": "Presupuesto académico en dbo.gasto_anuncio_diario + Conversiones SQL Server",
            "tipo_dato": "MIXTO",
            "etiqueta": "GASTO SIMULADO",
            "calculable": cpa_calculable,
            "observacion": cpa_nota,
        }

        # =====================================================================
        # KPI 2 — TASA DE INTERÉS EN MENÚ DIGITAL (TMD)
        # TMD = (Visitantes Carta / Visitantes Landing) × 100
        # =====================================================================
        # Denominador: navegadores únicos que visitaron la landing en el período
        q_vis_landing = db.session.query(func.count(distinct(VisitaWeb.id_visitante)))
        if f_inicio:
            q_vis_landing = q_vis_landing.filter(VisitaWeb.fecha_inicio >= f_inicio)
        if f_fin:
            q_vis_landing = q_vis_landing.filter(VisitaWeb.fecha_inicio <= f_fin)
        tmd_denominador = q_vis_landing.scalar() or 0

        # Numerador: navegadores únicos que accedieron a /carta/ (evento VISTA_CARTA)
        q_vis_carta = (
            db.session.query(func.count(distinct(VisitaWeb.id_visitante)))
            .join(EventoWeb, VisitaWeb.id_visita == EventoWeb.id_visita)
            .filter(EventoWeb.tipo == "VISTA_CARTA")
        )
        if f_inicio:
            q_vis_carta = q_vis_carta.filter(EventoWeb.fecha_evento >= f_inicio)
        if f_fin:
            q_vis_carta = q_vis_carta.filter(EventoWeb.fecha_evento <= f_fin)
        tmd_numerador = q_vis_carta.scalar() or 0

        if tmd_denominador > 0:
            tmd_valor = round((tmd_numerador / tmd_denominador) * 100.0, 2)
            tmd_formateado = f"{tmd_valor:.2f}%"
            tmd_calculable = True
        else:
            tmd_valor = None
            tmd_formateado = "N/D"
            tmd_calculable = False

        kpi_tmd = {
            "codigo": "TMD",
            "nombre": "Tasa de Interés en Menú Digital (TMD)",
            "formula": "(Visitantes Carta / Visitantes Landing) × 100",
            "valor": tmd_valor,
            "valor_formateado": tmd_formateado,
            "numerador": tmd_numerador,
            "numerador_label": "Navegadores únicos que abrieron /carta/",
            "denominador": tmd_denominador,
            "denominador_label": "Navegadores únicos que visitaron la Landing",
            "unidad": "%",
            "periodo": periodo_label,
            "procedencia": "dbo.visitante_web, dbo.visita_web, dbo.evento_web (VISTA_CARTA)",
            "tipo_dato": "REAL",
            "etiqueta": "REAL SQL SERVER",
            "calculable": tmd_calculable,
            "observacion": (
                "Mide la proporción de visitantes únicos que demuestran interés gastronómico activo "
                "explorando los 120 platos y 146 presentaciones de la carta digital."
            ),
        }

        # =====================================================================
        # KPI 3 — TASA DE CONVERSIÓN BUYER A LEAD (B1)
        # B1 = (BUYERS únicos convertidos a LEAD / BUYERS únicos totales) × 100
        # =====================================================================
        # Numerador: Personas reales únicas convertidas a LEAD con formulario confirmado
        q_b1_leads = (
            db.session.query(LeadConversion.id_persona).distinct()
            .filter(~LeadConversion.id_persona.in_(DEMO_PERSONA_IDS))
        )
        if f_inicio:
            q_b1_leads = q_b1_leads.filter(LeadConversion.fecha_conversion >= f_inicio)
        if f_fin:
            q_b1_leads = q_b1_leads.filter(LeadConversion.fecha_conversion <= f_fin)
        b1_numerador = len(q_b1_leads.all())

        # Denominador: Total de BUYERS únicos multicanal
        # Incluye:
        # 1. Prospectos no identificados de Meta (Facebook e Instagram con id_persona IS NULL)
        # 2. Personas únicas que entraron al funnel y fueron convertidas a LEAD
        q_meta_buyers = db.session.query(Buyer).filter(
            ~Buyer.id_buyer.in_(DEMO_BUYER_IDS),
            Buyer.id_persona.is_(None),
            Buyer.id_plataforma_origen.in_([1, 2]),
        )
        if f_inicio:
            q_meta_buyers = q_meta_buyers.filter(Buyer.fecha_primer_contacto >= f_inicio)
        if f_fin:
            q_meta_buyers = q_meta_buyers.filter(Buyer.fecha_primer_contacto <= f_fin)
        meta_buyers_count = q_meta_buyers.count()

        b1_denominador = meta_buyers_count + b1_numerador

        if b1_denominador > 0:
            b1_valor = round((b1_numerador / b1_denominador) * 100.0, 2)
            b1_formateado = f"{b1_valor:.2f}%"
            b1_calculable = True
        else:
            b1_valor = None
            b1_formateado = "N/D"
            b1_calculable = False

        kpi_b1 = {
            "codigo": "B1",
            "nombre": "Tasa de Conversión BUYER a LEAD (B1)",
            "formula": "(BUYERS únicos convertidos a LEAD / BUYERS únicos totales) × 100",
            "valor": b1_valor,
            "valor_formateado": b1_formateado,
            "numerador": b1_numerador,
            "numerador_label": "BUYERS únicos convertidos efectivamente a LEAD",
            "denominador": b1_denominador,
            "denominador_label": "BUYERS únicos totales (Meta + Landing)",
            "unidad": "%",
            "periodo": periodo_label,
            "procedencia": "dbo.buyer, dbo.persona, dbo.formulario_captacion, dbo.lead_conversion",
            "tipo_dato": "REAL",
            "etiqueta": "REAL SQL SERVER",
            "calculable": b1_calculable,
            "observacion": (
                f"Integración comercial de 3 canales: {meta_buyers_count} prospectos activos de Meta "
                f"+ {b1_numerador} LEADS únicos convertidos. Numerador <= Denominador garantizado."
            ),
        }

        return {
            "periodo": periodo_label,
            "cpa": kpi_cpa,
            "tmd": kpi_tmd,
            "b1": kpi_b1,
        }
