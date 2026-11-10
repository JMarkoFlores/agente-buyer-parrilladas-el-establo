"""
Modelos de Catálogo:
- Plataforma (dbo.plataforma)
- SegmentoCliente (dbo.segmento_cliente)
- ProductoCarta (dbo.producto_carta)
"""
from typing import Any
from sqlalchemy import Integer, String, Boolean, Numeric, CheckConstraint
from app.extensions import db


class Plataforma(db.Model):
    __tablename__ = "plataforma"
    __table_args__ = (
        CheckConstraint("codigo IN ('FACEBOOK','INSTAGRAM','LANDING_PAGE','WHATSAPP')", name="CK_plataforma_codigo"),
        {"schema": "dbo"}
    )

    id_plataforma = db.Column(Integer, primary_key=True, autoincrement=True)
    codigo = db.Column(String(20), nullable=False, unique=True)
    nombre_pagina = db.Column(String(150), nullable=False)
    url_pagina = db.Column(String(500), nullable=True)
    meta_account_id = db.Column(String(100), nullable=True)
    activa = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    campanas = db.relationship("Campana", back_populates="plataforma", lazy="select")
    publicaciones = db.relationship("Publicacion", back_populates="plataforma", lazy="select")
    buyers = db.relationship("Buyer", back_populates="plataforma_origen", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_plataforma": self.id_plataforma,
            "codigo": self.codigo,
            "nombre_pagina": self.nombre_pagina,
            "url_pagina": self.url_pagina,
            "meta_account_id": self.meta_account_id,
            "activa": self.activa,
        }


class SegmentoCliente(db.Model):
    __tablename__ = "segmento_cliente"
    __table_args__ = {"schema": "dbo"}

    id_segmento = db.Column(Integer, primary_key=True, autoincrement=True)
    nombre = db.Column(String(50), nullable=False, unique=True)
    descripcion = db.Column(String(250), nullable=True)

    # Relaciones
    campanas = db.relationship("Campana", back_populates="segmento_objetivo", lazy="select")
    personas = db.relationship("Persona", back_populates="segmento", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_segmento": self.id_segmento,
            "nombre": self.nombre,
            "descripcion": self.descripcion,
        }


class ProductoCarta(db.Model):
    __tablename__ = "producto_carta"
    __table_args__ = (
        CheckConstraint("categoria IN ('COMIDA','BEBIDA','POSTRE')", name="CK_producto_categoria"),
        CheckConstraint("peso_cantidad > 0", name="CK_producto_peso_pos"),
        CheckConstraint("peso_unidad IN ('g','ml','L')", name="CK_producto_peso_unidad"),
        CheckConstraint("precio >= 0", name="CK_producto_precio_pos"),
        {"schema": "dbo"}
    )

    id_producto = db.Column(Integer, primary_key=True, autoincrement=True)
    nombre = db.Column(String(120), nullable=False, unique=True)
    categoria = db.Column(String(15), nullable=False)
    descripcion = db.Column(String(500), nullable=True)
    estilo = db.Column(String(50), nullable=True)
    peso_cantidad = db.Column(Numeric(9, 2), nullable=True)
    peso_unidad = db.Column(String(5), nullable=True)
    precio = db.Column(Numeric(10, 2), nullable=False)
    activo = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    campanas_gancho = db.relationship("Campana", back_populates="producto_gancho", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_producto": self.id_producto,
            "nombre": self.nombre,
            "categoria": self.categoria,
            "descripcion": self.descripcion,
            "estilo": self.estilo,
            "peso_cantidad": float(self.peso_cantidad) if self.peso_cantidad is not None else None,
            "peso_unidad": self.peso_unidad,
            "precio": float(self.precio) if self.precio is not None else 0.0,
            "activo": self.activo,
        }
