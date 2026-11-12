"""
Modelos de Catálogo:
- Plataforma (dbo.plataforma)
- SegmentoCliente (dbo.segmento_cliente)
- CategoriaProducto (dbo.categoria_producto)
- TipoCorte (dbo.tipo_corte)
- TerminoCoccion (dbo.termino_coccion)
- ProductoCarta (dbo.producto_carta)
- PresentacionProducto (dbo.presentacion_producto)
"""
from typing import Any
from sqlalchemy import Integer, String, Boolean, Numeric, ForeignKey
from app.extensions import db


class Plataforma(db.Model):
    __tablename__ = "plataforma"
    __table_args__ = {"schema": "dbo"}

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


class CategoriaProducto(db.Model):
    __tablename__ = "categoria_producto"
    __table_args__ = {"schema": "dbo"}

    id_categoria = db.Column(String(20), primary_key=True)
    titulo = db.Column(String(100), nullable=False)
    descripcion_nota = db.Column(String(500), nullable=True)
    orden = db.Column(Integer, nullable=False, default=0)
    activa = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    productos = db.relationship("ProductoCarta", back_populates="categoria_rel", lazy="select", order_by="ProductoCarta.orden")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id": self.id_categoria,
            "id_categoria": self.id_categoria,
            "titulo": self.titulo,
            "nota": self.descripcion_nota,
            "descripcion_nota": self.descripcion_nota,
            "orden": self.orden,
            "activa": self.activa,
        }


class TipoCorte(db.Model):
    __tablename__ = "tipo_corte"
    __table_args__ = {"schema": "dbo"}

    id_tipo_corte = db.Column(Integer, primary_key=True, autoincrement=True)
    codigo = db.Column(String(30), nullable=False, unique=True)
    nombre = db.Column(String(100), nullable=False)
    descripcion = db.Column(String(250), nullable=True)
    activo = db.Column(Boolean, nullable=False, default=True)

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_tipo_corte": self.id_tipo_corte,
            "codigo": self.codigo,
            "nombre": self.nombre,
            "descripcion": self.descripcion,
            "activo": self.activo,
        }


class TerminoCoccion(db.Model):
    __tablename__ = "termino_coccion"
    __table_args__ = {"schema": "dbo"}

    id_termino = db.Column(Integer, primary_key=True, autoincrement=True)
    codigo = db.Column(String(30), nullable=False, unique=True)
    nombre = db.Column(String(50), nullable=False)
    descripcion = db.Column(String(250), nullable=True)
    orden = db.Column(Integer, nullable=False, default=0)
    activo = db.Column(Boolean, nullable=False, default=True)

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_termino": self.id_termino,
            "codigo": self.codigo,
            "nombre": self.nombre,
            "descripcion": self.descripcion,
            "orden": self.orden,
            "activo": self.activo,
        }


class ProductoCarta(db.Model):
    __tablename__ = "producto_carta"
    __table_args__ = {"schema": "dbo"}

    id_producto = db.Column(Integer, primary_key=True, autoincrement=True)
    nombre = db.Column(String(120), nullable=False)
    categoria = db.Column(String(30), nullable=False)
    id_categoria = db.Column(String(20), ForeignKey("dbo.categoria_producto.id_categoria"), nullable=True)
    grupo_comercial = db.Column(String(100), nullable=True)
    id_tipo_corte = db.Column(Integer, ForeignKey("dbo.tipo_corte.id_tipo_corte"), nullable=True)
    pais_origen = db.Column(String(50), nullable=True)
    descripcion = db.Column(String(500), nullable=True)
    estilo = db.Column(String(50), nullable=True)
    peso_cantidad = db.Column(Numeric(9, 2), nullable=True)
    peso_unidad = db.Column(String(20), nullable=True)
    precio = db.Column(Numeric(10, 2), nullable=False)
    es_apto_favorito = db.Column(Boolean, nullable=False, default=False)
    destacado = db.Column(Boolean, nullable=False, default=False)
    imagen = db.Column(String(255), nullable=True)
    orden = db.Column(Integer, nullable=False, default=0)
    activo = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    categoria_rel = db.relationship("CategoriaProducto", back_populates="productos", lazy="joined")
    tipo_corte_rel = db.relationship("TipoCorte", lazy="joined")
    presentaciones = db.relationship("PresentacionProducto", back_populates="producto", lazy="select", order_by="PresentacionProducto.orden")
    campanas_gancho = db.relationship("Campana", back_populates="producto_gancho", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_producto": self.id_producto,
            "nombre": self.nombre,
            "categoria": self.categoria,
            "id_categoria": self.id_categoria,
            "grupo": self.grupo_comercial,
            "grupo_comercial": self.grupo_comercial,
            "descripcion": self.descripcion,
            "estilo": self.estilo,
            "pais_origen": self.pais_origen,
            "peso_cantidad": float(self.peso_cantidad) if self.peso_cantidad is not None else None,
            "peso_unidad": self.peso_unidad,
            "precio": float(self.precio) if self.precio is not None else 0.0,
            "es_apto_favorito": self.es_apto_favorito,
            "destacado": self.destacado,
            "imagen": self.imagen,
            "orden": self.orden,
            "activo": self.activo,
        }

    def to_dict_full(self) -> dict[str, Any]:
        d = self.to_dict()
        d["presentaciones"] = [pres.to_dict() for pres in self.presentaciones if pres.activo]
        return d


class PresentacionProducto(db.Model):
    __tablename__ = "presentacion_producto"
    __table_args__ = {"schema": "dbo"}

    id_presentacion = db.Column(Integer, primary_key=True, autoincrement=True)
    id_producto = db.Column(Integer, ForeignKey("dbo.producto_carta.id_producto"), nullable=False)
    nombre_presentacion = db.Column(String(150), nullable=False)
    precio = db.Column(Numeric(10, 2), nullable=False)
    peso_volumen_cantidad = db.Column(Numeric(9, 2), nullable=True)
    unidad_medida = db.Column(String(20), nullable=True)
    variedad_vino = db.Column(String(100), nullable=True)
    descripcion_presentacion = db.Column(String(500), nullable=True)
    destacado = db.Column(Boolean, nullable=False, default=False)
    imagen = db.Column(String(255), nullable=True)
    orden = db.Column(Integer, nullable=False, default=0)
    activo = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    producto = db.relationship("ProductoCarta", back_populates="presentaciones", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_presentacion": self.id_presentacion,
            "id_producto": self.id_producto,
            "nombre": self.producto.nombre if self.producto else "",
            "nombre_presentacion": self.nombre_presentacion,
            "detalle": self.nombre_presentacion if self.nombre_presentacion != "Porción estándar" else None,
            "precio": float(self.precio),
            "peso_volumen_cantidad": float(self.peso_volumen_cantidad) if self.peso_volumen_cantidad is not None else None,
            "unidad_medida": self.unidad_medida,
            "variedad_vino": self.variedad_vino,
            "descripcion": self.descripcion_presentacion or (self.producto.descripcion if self.producto else None),
            "destacado": self.destacado or (self.producto.destacado if self.producto else False),
            "imagen": self.imagen or (self.producto.imagen if self.producto else None),
            "orden": self.orden,
            "activo": self.activo,
        }
