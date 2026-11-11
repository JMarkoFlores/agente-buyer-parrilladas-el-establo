"""
Modelos de Persona y Prospecto (BUYER):
- Persona (dbo.persona)
- Buyer (dbo.buyer)
- PersonaRedSocial (dbo.persona_red_social)
- InteraccionPublicacion (dbo.interaccion_publicacion)
"""
from typing import Any
from datetime import datetime, date
from sqlalchemy import Integer, BigInteger, String, Date, DateTime, ForeignKey, UniqueConstraint, CheckConstraint
from app.extensions import db


class Persona(db.Model):
    __tablename__ = "persona"
    __table_args__ = (
        CheckConstraint("fase_actual IN ('BUYER','LEAD')", name="CK_persona_fase"),
        CheckConstraint("telefono IS NOT NULL OR email IS NOT NULL", name="CK_persona_contacto"),
        {"schema": "dbo"}
    )

    id_persona = db.Column(BigInteger, primary_key=True, autoincrement=True)
    nombres = db.Column(String(100), nullable=False)
    apellidos = db.Column(String(100), nullable=False)
    telefono = db.Column(String(20), nullable=True, unique=True)
    email = db.Column(String(150), nullable=True, unique=True)
    fecha_nacimiento = db.Column(Date, nullable=True)
    id_segmento = db.Column(Integer, ForeignKey("dbo.segmento_cliente.id_segmento"), nullable=True)
    fecha_registro = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    fase_actual = db.Column(String(10), nullable=False, default="LEAD")
    consentimiento_datos_fecha = db.Column(DateTime, nullable=True)
    consentimiento_marketing_fecha = db.Column(DateTime, nullable=True)

    # Relaciones
    segmento = db.relationship("SegmentoCliente", back_populates="personas", lazy="joined")
    buyers = db.relationship("Buyer", back_populates="persona", lazy="select")
    cuentas_red_social = db.relationship("PersonaRedSocial", back_populates="persona", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_persona": self.id_persona,
            "nombres": self.nombres,
            "apellidos": self.apellidos,
            "nombre_completo": f"{self.nombres} {self.apellidos}".strip(),
            "telefono": self.telefono,
            "email": self.email,
            "fecha_nacimiento": self.fecha_nacimiento.isoformat() if self.fecha_nacimiento else None,
            "id_segmento": self.id_segmento,
            "segmento_nombre": self.segmento.nombre if self.segmento else None,
            "fecha_registro": self.fecha_registro.isoformat() if self.fecha_registro else None,
            "fase_actual": self.fase_actual,
            "consentimiento_datos": self.consentimiento_datos_fecha is not None,
            "consentimiento_marketing": self.consentimiento_marketing_fecha is not None,
        }


class Buyer(db.Model):
    __tablename__ = "buyer"
    __table_args__ = (
        CheckConstraint("estado IN ('BUYER','CONVERTIDO_LEAD','DESCARTADO')", name="CK_buyer_estado"),
        {"schema": "dbo"}
    )

    id_buyer = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=True)
    id_plataforma_origen = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=False)
    id_publicacion_origen = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=True)
    id_anuncio_origen = db.Column(Integer, ForeignKey("dbo.anuncio.id_anuncio"), nullable=True)
    referencia_externa = db.Column(String(150), nullable=True)
    fecha_primer_contacto = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    estado = db.Column(String(15), nullable=False, default="BUYER")
    fecha_conversion = db.Column(DateTime, nullable=True)

    # Relaciones
    persona = db.relationship("Persona", back_populates="buyers", lazy="joined")
    plataforma_origen = db.relationship("Plataforma", back_populates="buyers", lazy="joined")
    publicacion_origen = db.relationship("Publicacion", lazy="joined")
    anuncio_origen = db.relationship("Anuncio", lazy="joined")
    interacciones = db.relationship("InteraccionPublicacion", back_populates="buyer", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_buyer": self.id_buyer,
            "id_persona": self.id_persona,
            "persona": self.persona.to_dict() if self.persona else None,
            "id_plataforma_origen": self.id_plataforma_origen,
            "plataforma_codigo": self.plataforma_origen.codigo if self.plataforma_origen else None,
            "id_publicacion_origen": self.id_publicacion_origen,
            "id_anuncio_origen": self.id_anuncio_origen,
            "referencia_externa": self.referencia_externa,
            "fecha_primer_contacto": self.fecha_primer_contacto.isoformat() if self.fecha_primer_contacto else None,
            "estado": self.estado,
            "fecha_conversion": self.fecha_conversion.isoformat() if self.fecha_conversion else None,
        }


class PersonaRedSocial(db.Model):
    __tablename__ = "persona_red_social"
    __table_args__ = (
        CheckConstraint("metodo_vinculacion IN ('VERIFICACION','FORMULARIO','AUTORIZACION')", name="CK_persona_rs_metodo"),
        {"schema": "dbo"}
    )

    id_cuenta = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_persona = db.Column(BigInteger, ForeignKey("dbo.persona.id_persona"), nullable=False)
    id_plataforma = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=False)
    usuario = db.Column(String(150), nullable=True)
    id_usuario_externo = db.Column(String(150), nullable=True)
    fecha_vinculacion = db.Column(DateTime, nullable=False, default=datetime.utcnow)
    metodo_vinculacion = db.Column(String(30), nullable=False)

    # Relaciones
    persona = db.relationship("Persona", back_populates="cuentas_red_social", lazy="joined")
    plataforma = db.relationship("Plataforma", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_cuenta": self.id_cuenta,
            "id_persona": self.id_persona,
            "id_plataforma": self.id_plataforma,
            "plataforma_codigo": self.plataforma.codigo if self.plataforma else None,
            "usuario": self.usuario,
            "id_usuario_externo": self.id_usuario_externo,
            "fecha_vinculacion": self.fecha_vinculacion.isoformat() if self.fecha_vinculacion else None,
            "metodo_vinculacion": self.metodo_vinculacion,
        }


class InteraccionPublicacion(db.Model):
    __tablename__ = "interaccion_publicacion"
    __table_args__ = (
        UniqueConstraint("id_publicacion", "id_interaccion_externa", name="UQ_interaccion_publicacion"),
        CheckConstraint("tipo IN ('COMENTARIO','RESPUESTA','REACCION')", name="CK_interaccion_tipo"),
        {"schema": "dbo"}
    )

    id_interaccion = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_publicacion = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=False)
    id_buyer = db.Column(BigInteger, ForeignKey("dbo.buyer.id_buyer"), nullable=True)
    id_interaccion_externa = db.Column(String(150), nullable=False)
    tipo = db.Column(String(15), nullable=False)
    id_usuario_externo = db.Column(String(150), nullable=True)
    nombre_visible = db.Column(String(150), nullable=True)
    texto = db.Column(String(2000), nullable=True)
    fecha_interaccion = db.Column(DateTime, nullable=False)
    fecha_ingesta = db.Column(DateTime, nullable=False, default=datetime.utcnow)

    # Relaciones
    publicacion = db.relationship("Publicacion", back_populates="interacciones", lazy="joined")
    buyer = db.relationship("Buyer", back_populates="interacciones", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_interaccion": self.id_interaccion,
            "id_publicacion": self.id_publicacion,
            "id_buyer": self.id_buyer,
            "id_interaccion_externa": self.id_interaccion_externa,
            "origen": "DEMO" if (self.id_interaccion_externa and self.id_interaccion_externa.startswith("DEMO_")) else "META_REAL",
            "tipo": self.tipo,
            "id_usuario_externo": self.id_usuario_externo,
            "nombre_visible": self.nombre_visible,
            "texto": self.texto,
            "fecha_interaccion": self.fecha_interaccion.isoformat() if self.fecha_interaccion else None,
            "fecha_ingesta": self.fecha_ingesta.isoformat() if self.fecha_ingesta else None,
        }
