"""
Modelos de Conversión y Captación:
- FormularioCaptacion (dbo.formulario_captacion)
- LeadConversion (dbo.lead_conversion)
- HistorialFases (dbo.historial_fases)
"""
from typing import Any
from datetime import datetime
from sqlalchemy import Integer, BigInteger, String, Boolean, DateTime, ForeignKey, UniqueConstraint, CheckConstraint
from app.extensions import db


class FormularioCaptacion(db.Model):
    __tablename__ = "formulario_captacion"
    __table_args__ = (
        CheckConstraint("acepta_politica_datos = 1", name="CK_formulario_politica"),
        CheckConstraint("NOT (id_visita IS NOT NULL AND id_sesion_whatsapp IS NOT NULL)", name="CK_formulario_un_origen"),
        {"schema": "dbo"}
    )

    id_formulario = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=False)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=False)
    id_plataforma_origen = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=False)
    id_publicacion_origen = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=True)
    id_visita = db.Column(BigInteger, ForeignKey("dbo.visita_web.id_visita"), nullable=True)
    id_sesion_whatsapp = db.Column(BigInteger, ForeignKey("dbo.sesion_whatsapp.id_sesion"), nullable=True)
    id_producto_favorito = db.Column(Integer, ForeignKey("dbo.producto_carta.id_producto"), nullable=True)
    fecha_envio = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    acepta_politica_datos = db.Column(Boolean, nullable=False, default=True)
    acepta_marketing = db.Column(Boolean, nullable=False, default=False)

    # Relaciones
    persona = db.relationship("Persona", lazy="joined")
    buyer = db.relationship("Buyer", lazy="joined")
    plataforma = db.relationship("Plataforma", lazy="joined")
    publicacion = db.relationship("Publicacion", lazy="joined")
    producto_favorito = db.relationship("ProductoCarta", lazy="joined")
    visita = db.relationship("VisitaWeb", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_formulario": self.id_formulario,
            "id_persona": self.id_persona,
            "id_buyer": self.id_buyer,
            "id_plataforma_origen": self.id_plataforma_origen,
            "plataforma_codigo": self.plataforma.codigo if self.plataforma else None,
            "id_publicacion_origen": self.id_publicacion_origen,
            "id_producto_favorito": self.id_producto_favorito,
            "fecha_envio": self.fecha_envio.isoformat() if self.fecha_envio else None,
            "acepta_politica_datos": self.acepta_politica_datos,
            "acepta_marketing": self.acepta_marketing,
        }


class LeadConversion(db.Model):
    __tablename__ = "lead_conversion"
    __table_args__ = {"schema": "dbo"}

    id_conversion = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=False, unique=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=False)
    id_formulario = db.Column(BigInteger, ForeignKey("dbo.formulario_captacion.id_formulario"), nullable=False, unique=True)
    fecha_conversion = db.Column(DateTime, nullable=False)

    # Relaciones
    buyer = db.relationship("Buyer", lazy="joined")
    persona = db.relationship("Persona", lazy="joined")
    formulario = db.relationship("FormularioCaptacion", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_conversion": self.id_conversion,
            "id_buyer": self.id_buyer,
            "id_persona": self.id_persona,
            "id_formulario": self.id_formulario,
            "fecha_conversion": self.fecha_conversion.isoformat() if self.fecha_conversion else None,
        }


class HistorialFases(db.Model):
    __tablename__ = "historial_fases"
    __table_args__ = (
        UniqueConstraint("id_persona", "fase", name="UQ_historial_fases"),
        CheckConstraint("fase IN ('BUYER','LEAD')", name="CK_historial_fase"),
        CheckConstraint("fase <> 'LEAD' OR id_formulario IS NOT NULL", name="CK_historial_lead"),
        {"schema": "dbo"}
    )

    id_historial = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=False)
    fase = db.Column(String(10), nullable=False)
    fecha_cambio = db.Column(DateTime, nullable=False)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=True)
    id_formulario = db.Column(BigInteger, ForeignKey("dbo.formulario_captacion.id_formulario"), nullable=True)

    # Relaciones
    persona = db.relationship("Persona", lazy="joined")
    buyer = db.relationship("Buyer", lazy="joined")
    formulario = db.relationship("FormularioCaptacion", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_historial": self.id_historial,
            "id_persona": self.id_persona,
            "fase": self.fase,
            "fecha_cambio": self.fecha_cambio.isoformat() if self.fecha_cambio else None,
            "id_buyer": self.id_buyer,
            "id_formulario": self.id_formulario,
        }
