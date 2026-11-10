"""
Modelos de Integración con WhatsApp:
- SesionWhatsapp (dbo.sesion_whatsapp)
- MensajeWhatsapp (dbo.mensaje_whatsapp)
"""
from typing import Any
from datetime import datetime
from sqlalchemy import BigInteger, String, Text, DateTime, ForeignKey, CheckConstraint
from app.extensions import db


class SesionWhatsapp(db.Model):
    __tablename__ = "sesion_whatsapp"
    __table_args__ = (
        CheckConstraint("estado IN ('ABIERTA','CERRADA')", name="CK_sesion_whatsapp_estado"),
        CheckConstraint("fecha_ultimo_mensaje >= fecha_inicio", name="CK_sesion_whatsapp_fechas"),
        {"schema": "dbo"}
    )

    id_sesion = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=True)
    telefono_cliente = db.Column(String(20), nullable=False)
    fecha_inicio = db.Column(DateTime, nullable=False)
    fecha_ultimo_mensaje = db.Column(DateTime, nullable=False)
    estado = db.Column(String(15), nullable=False, default="ABIERTA")
    origen = db.Column(String(30), nullable=True)

    # Relaciones
    buyer = db.relationship("Buyer", lazy="joined")
    persona = db.relationship("Persona", lazy="joined")
    mensajes = db.relationship("MensajeWhatsapp", back_populates="sesion", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_sesion": self.id_sesion,
            "id_buyer": self.id_buyer,
            "id_persona": self.id_persona,
            "telefono_cliente": self.telefono_cliente,
            "fecha_inicio": self.fecha_inicio.isoformat() if self.fecha_inicio else None,
            "fecha_ultimo_mensaje": self.fecha_ultimo_mensaje.isoformat() if self.fecha_ultimo_mensaje else None,
            "estado": self.estado,
            "origen": self.origen,
        }


class MensajeWhatsapp(db.Model):
    __tablename__ = "mensaje_whatsapp"
    __table_args__ = (
        CheckConstraint("direccion IN ('ENTRANTE','SALIENTE')", name="CK_mensaje_direccion"),
        CheckConstraint("tipo IN ('TEXTO','BOTONES','INTERACTIVO','IMAGEN','OTRO')", name="CK_mensaje_tipo"),
        {"schema": "dbo"}
    )

    id_mensaje = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_sesion = db.Column(BigInteger, ForeignKey("dbo.sesion_whatsapp.id_sesion"), nullable=False)
    wamid = db.Column(String(200), nullable=True, unique=True)
    direccion = db.Column(String(10), nullable=False)
    tipo = db.Column(String(20), nullable=False)
    contenido = db.Column(Text, nullable=True)
    opcion_seleccionada = db.Column(String(50), nullable=True)
    fecha_mensaje = db.Column(DateTime, nullable=False)
    estado_entrega = db.Column(String(20), nullable=True)

    # Relaciones
    sesion = db.relationship("SesionWhatsapp", back_populates="mensajes", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_mensaje": self.id_mensaje,
            "id_sesion": self.id_sesion,
            "wamid": self.wamid,
            "direccion": self.direccion,
            "tipo": self.tipo,
            "contenido": self.contenido,
            "opcion_seleccionada": self.opcion_seleccionada,
            "fecha_mensaje": self.fecha_mensaje.isoformat() if self.fecha_mensaje else None,
            "estado_entrega": self.estado_entrega,
        }
