"""
Modelos de Auditoría y Agentes:
- EventoIntegracion (dbo.evento_integracion)
- AccionAgente (dbo.accion_agente)
"""
from typing import Any
from datetime import datetime
from sqlalchemy import BigInteger, String, DateTime, ForeignKey, UniqueConstraint, CheckConstraint
from app.extensions import db


class EventoIntegracion(db.Model):
    __tablename__ = "evento_integracion"
    __table_args__ = (
        UniqueConstraint("proveedor", "id_evento_externo", name="UQ_evento_integracion"),
        CheckConstraint("proveedor IN ('META','WHATSAPP','LANDING')", name="CK_evento_proveedor"),
        CheckConstraint("estado IN ('RECIBIDO','PROCESADO','ERROR')", name="CK_evento_estado"),
        {"schema": "dbo"}
    )

    id_evento = db.Column(BigInteger, primary_key=True, autoincrement=True)
    proveedor = db.Column(String(20), nullable=False)
    id_evento_externo = db.Column(String(200), nullable=False)
    tipo = db.Column(String(50), nullable=False)
    recibido_en = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    procesado_en = db.Column(DateTime, nullable=True)
    estado = db.Column(String(15), nullable=False, default="RECIBIDO")
    error_resumen = db.Column(String(300), nullable=True)

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_evento": self.id_evento,
            "proveedor": self.proveedor,
            "id_evento_externo": self.id_evento_externo,
            "tipo": self.tipo,
            "recibido_en": self.recibido_en.isoformat() if self.recibido_en else None,
            "procesado_en": self.procesado_en.isoformat() if self.procesado_en else None,
            "estado": self.estado,
            "error_resumen": self.error_resumen,
        }


class AccionAgente(db.Model):
    __tablename__ = "accion_agente"
    __table_args__ = (
        CheckConstraint("resultado IN ('EXITOSO','FALLIDO','PENDIENTE')", name="CK_accion_resultado"),
        {"schema": "dbo"}
    )

    id_accion = db.Column(BigInteger, primary_key=True, autoincrement=True)
    nombre_agente = db.Column(String(60), nullable=False)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=True)
    id_sesion_whatsapp = db.Column(BigInteger, ForeignKey("dbo.sesion_whatsapp.id_sesion"), nullable=True)
    accion = db.Column(String(50), nullable=False)
    detalle = db.Column(String(500), nullable=True)
    resultado = db.Column(String(20), nullable=False)
    fecha_ejecucion = db.Column(DateTime, nullable=False, default=datetime.utcnow)

    # Relaciones
    buyer = db.relationship("Buyer", lazy="joined")
    sesion_whatsapp = db.relationship("SesionWhatsapp", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_accion": self.id_accion,
            "nombre_agente": self.nombre_agente,
            "id_buyer": self.id_buyer,
            "id_buyer_asociado": self.id_buyer,
            "id_sesion_whatsapp": self.id_sesion_whatsapp,
            "accion": self.accion,
            "detalle": self.detalle,
            "detalles": self.detalle,
            "resultado": self.resultado,
            "fecha_ejecucion": self.fecha_ejecucion.isoformat() if self.fecha_ejecucion else None,
        }
