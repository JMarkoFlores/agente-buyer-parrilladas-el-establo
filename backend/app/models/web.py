"""
Modelos de Interacciones Web / Landing Page:
- VisitanteWeb (dbo.visitante_web)
- VisitaWeb (dbo.visita_web)
- EventoWeb (dbo.evento_web)
"""
from typing import Any
from datetime import datetime
from sqlalchemy import Integer, BigInteger, String, DateTime, ForeignKey, CheckConstraint
from sqlalchemy.dialects.mssql import UNIQUEIDENTIFIER
from app.extensions import db


class VisitanteWeb(db.Model):
    __tablename__ = "visitante_web"
    __table_args__ = (
        CheckConstraint("dispositivo_tipo IN ('MOVIL','ESCRITORIO','TABLETA','DESCONOCIDO')", name="CK_visitante_dispositivo"),
        CheckConstraint("fecha_ultima_visita >= fecha_primera_visita", name="CK_visitante_fechas"),
        CheckConstraint("cantidad_visitas >= 0", name="CK_visitante_cantidad"),
        {"schema": "dbo"}
    )

    id_visitante = db.Column(BigInteger, primary_key=True, autoincrement=True)
    token_visitante = db.Column(UNIQUEIDENTIFIER, nullable=False, unique=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=True)
    dispositivo_tipo = db.Column(String(20), nullable=True)
    fecha_primera_visita = db.Column(DateTime, nullable=False)
    fecha_ultima_visita = db.Column(DateTime, nullable=False)
    cantidad_visitas = db.Column(Integer, nullable=False, default=0)

    # Relaciones
    persona = db.relationship("Persona", lazy="joined")
    visitas = db.relationship("VisitaWeb", back_populates="visitante", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_visitante": self.id_visitante,
            "token_visitante": str(self.token_visitante),
            "id_persona": self.id_persona,
            "dispositivo_tipo": self.dispositivo_tipo,
            "fecha_primera_visita": self.fecha_primera_visita.isoformat() if self.fecha_primera_visita else None,
            "fecha_ultima_visita": self.fecha_ultima_visita.isoformat() if self.fecha_ultima_visita else None,
            "cantidad_visitas": self.cantidad_visitas,
        }


class VisitaWeb(db.Model):
    __tablename__ = "visita_web"
    __table_args__ = (
        CheckConstraint("fecha_ultima_actividad >= fecha_inicio", name="CK_visita_fecha"),
        {"schema": "dbo"}
    )

    id_visita = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_visitante = db.Column(BigInteger, ForeignKey("dbo.visitante_web.id_visitante"), nullable=False)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=True)
    fecha_inicio = db.Column(DateTime, nullable=False)
    fecha_ultima_actividad = db.Column(DateTime, nullable=False)
    utm_source = db.Column(String(100), nullable=True)
    utm_campaign = db.Column(String(150), nullable=True)
    id_publicacion_origen = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=True)

    # Relaciones
    visitante = db.relationship("VisitanteWeb", back_populates="visitas", lazy="joined")
    buyer = db.relationship("Buyer", lazy="joined")
    publicacion_origen = db.relationship("Publicacion", lazy="joined")
    eventos = db.relationship("EventoWeb", back_populates="visita", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_visita": self.id_visita,
            "id_visitante": self.id_visitante,
            "id_buyer": self.id_buyer,
            "fecha_inicio": self.fecha_inicio.isoformat() if self.fecha_inicio else None,
            "fecha_ultima_actividad": self.fecha_ultima_actividad.isoformat() if self.fecha_ultima_actividad else None,
            "utm_source": self.utm_source,
            "utm_campaign": self.utm_campaign,
            "id_publicacion_origen": self.id_publicacion_origen,
        }


class EventoWeb(db.Model):
    __tablename__ = "evento_web"
    __table_args__ = (
        CheckConstraint(
            "tipo IN ('VER_MENU','CLIC_FORMULARIO','CLIC_WHATSAPP','ENVIO_FORMULARIO','CLIC_CARTA','VISTA_CARTA','VER_CARTA')",
            name="CK_evento_web_tipo",
        ),
        {"schema": "dbo"},
    )

    id_evento = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_visita = db.Column(BigInteger, ForeignKey("dbo.visita_web.id_visita"), nullable=False)
    tipo = db.Column(String(30), nullable=False)
    id_producto = db.Column(Integer, ForeignKey("dbo.producto_carta.id_producto"), nullable=True)
    fecha_evento = db.Column(DateTime, nullable=False)
    detalle = db.Column(String(300), nullable=True)

    # Relaciones
    visita = db.relationship("VisitaWeb", back_populates="eventos", lazy="joined")
    producto = db.relationship("ProductoCarta", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_evento": self.id_evento,
            "id_visita": self.id_visita,
            "tipo": self.tipo,
            "id_producto": self.id_producto,
            "producto_nombre": self.producto.nombre if self.producto else None,
            "fecha_evento": self.fecha_evento.isoformat() if self.fecha_evento else None,
            "detalle": self.detalle,
        }
