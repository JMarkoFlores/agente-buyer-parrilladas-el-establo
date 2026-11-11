"""
Modelo SQLAlchemy para dbo.respuesta_automatica.
Almacena el ciclo de vida de propuestas y envíos de respuestas automáticas
a comentarios de Facebook e Instagram para la captación de BUYERS.
"""
from __future__ import annotations

from typing import Any
from datetime import datetime
from sqlalchemy import (
    BigInteger,
    Integer,
    String,
    Unicode,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    CheckConstraint,
    Index,
)
from sqlalchemy.orm import relationship
from app.extensions import db


class RespuestaAutomatica(db.Model):
    __tablename__ = "respuesta_automatica"
    __table_args__ = (
        UniqueConstraint("id_interaccion", name="UQ_respuesta_interaccion"),
        CheckConstraint(
            "estado IN ('PENDIENTE', 'APROBADA', 'SIMULADA', 'ENVIANDO', 'ENVIADA', 'FALLIDA', 'OMITIDA', 'REQUIERE_REVISION')",
            name="CK_respuesta_estado",
        ),
        CheckConstraint(
            "tipo_envio IN ('AUTOMATICO', 'MANUAL_APROBADO', 'SIMULADO')",
            name="CK_respuesta_tipo_envio",
        ),
        {"schema": "dbo"},
    )

    id_respuesta = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_interaccion = db.Column(
        BigInteger,
        ForeignKey("dbo.interaccion_publicacion.id_interaccion"),
        nullable=False,
    )
    id_buyer = db.Column(
        BigInteger,
        ForeignKey("dbo.buyer.id_buyer"),
        nullable=True,
    )
    id_plataforma = db.Column(
        Integer,
        ForeignKey("dbo.plataforma.id_plataforma"),
        nullable=False,
    )
    intencion_detectada = db.Column(String(50), nullable=True)
    texto_respuesta = db.Column(Unicode(2000), nullable=False)
    id_respuesta_meta = db.Column(String(150), nullable=True)
    estado = db.Column(String(25), nullable=False, default="PENDIENTE")
    tipo_envio = db.Column(String(20), nullable=False, default="AUTOMATICO")
    fecha_generacion = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    fecha_envio = db.Column(DateTime, nullable=True)
    error_detalle = db.Column(Unicode(1000), nullable=True)

    # Relaciones
    interaccion = relationship("InteraccionPublicacion", backref="respuestas_automaticas")
    buyer = relationship("Buyer", backref="respuestas_automaticas")
    plataforma = relationship("Plataforma")

    def to_dict(self) -> dict[str, Any]:
        """Serializa la respuesta automática a formato JSON para el frontend React."""
        comentario_info: dict[str, Any] | None = None
        id_publicacion: int | None = None
        url_publicacion: str | None = None

        if self.interaccion:
            comentario_info = {
                "id_interaccion": self.interaccion.id_interaccion,
                "id_interaccion_externa": self.interaccion.id_interaccion_externa,
                "nombre_usuario": self.interaccion.nombre_visible,
                "texto": self.interaccion.texto,
                "fecha_interaccion": (
                    self.interaccion.fecha_interaccion.isoformat()
                    if self.interaccion.fecha_interaccion
                    else None
                ),
                "tipo": self.interaccion.tipo,
            }
            if self.interaccion.publicacion:
                id_publicacion = self.interaccion.publicacion.id_publicacion
                url_publicacion = self.interaccion.publicacion.url_publicacion

        plataforma_codigo = (
            self.plataforma.codigo if self.plataforma else ("FACEBOOK" if self.id_plataforma == 1 else "INSTAGRAM")
        )

        return {
            "id_respuesta": self.id_respuesta,
            "id_interaccion": self.id_interaccion,
            "id_buyer": self.id_buyer,
            "id_plataforma": self.id_plataforma,
            "plataforma_codigo": plataforma_codigo,
            "intencion_detectada": self.intencion_detectada or "OTRO",
            "texto_respuesta": self.texto_respuesta,
            "id_respuesta_meta": self.id_respuesta_meta,
            "estado": self.estado,
            "tipo_envio": self.tipo_envio,
            "fecha_generacion": self.fecha_generacion.isoformat() if self.fecha_generacion else None,
            "fecha_envio": self.fecha_envio.isoformat() if self.fecha_envio else None,
            "error_detalle": self.error_detalle,
            "comentario_original": comentario_info,
            "id_publicacion": id_publicacion,
            "url_publicacion": url_publicacion,
        }
