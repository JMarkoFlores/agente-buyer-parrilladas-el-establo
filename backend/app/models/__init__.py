"""
Módulo central de modelos SQLAlchemy para Agente Inteligente BUYER - Parrilladas El Establo.
Exporta las 22 entidades de la base de datos SQL Server 'buyer'.
"""
from app.models.catalogo import (
    Plataforma,
    SegmentoCliente,
    CategoriaProducto,
    TipoCorte,
    TerminoCoccion,
    ProductoCarta,
    PresentacionProducto,
)
from app.models.marketing import (
    Campana,
    Publicacion,
    Anuncio,
    GastoAnuncioDiario,
    MetricaPublicacionDiaria,
)
from app.models.persona import (
    Persona,
    Buyer,
    PersonaRedSocial,
    InteraccionPublicacion,
)
from app.models.web import VisitanteWeb, VisitaWeb, EventoWeb
from app.models.whatsapp import SesionWhatsapp, MensajeWhatsapp
from app.models.conversion import FormularioCaptacion, LeadConversion, HistorialFases
from app.models.auditoria import EventoIntegracion, AccionAgente
from app.models.respuesta_automatica import RespuestaAutomatica

__all__ = [
    # 1. Catálogos (7)
    "Plataforma",
    "SegmentoCliente",
    "CategoriaProducto",
    "TipoCorte",
    "TerminoCoccion",
    "ProductoCarta",
    "PresentacionProducto",
    # 2. Marketing (5)
    "Campana",
    "Publicacion",
    "Anuncio",
    "GastoAnuncioDiario",
    "MetricaPublicacionDiaria",
    # 3. Personas y BUYER (4)
    "Persona",
    "Buyer",
    "PersonaRedSocial",
    "InteraccionPublicacion",
    # 4. Web / Landing (3)
    "VisitanteWeb",
    "VisitaWeb",
    "EventoWeb",
    # 5. WhatsApp (2)
    "SesionWhatsapp",
    "MensajeWhatsapp",
    # 6. Conversión / Leads (3)
    "FormularioCaptacion",
    "LeadConversion",
    "HistorialFases",
    # 7. Auditoría / Agentes (2)
    "EventoIntegracion",
    "AccionAgente",
    # 8. Automatización de Respuestas (1)
    "RespuestaAutomatica",
]
