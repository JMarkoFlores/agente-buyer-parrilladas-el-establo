"""
Modelos de Marketing Publicitario:
- Campana (dbo.campana)
- Publicacion (dbo.publicacion)
- Anuncio (dbo.anuncio)
- GastoAnuncioDiario (dbo.gasto_anuncio_diario)
- MetricaPublicacionDiaria (dbo.metrica_publicacion_diaria)
"""
from typing import Any
from datetime import datetime, date
from sqlalchemy import Integer, BigInteger, String, Text, Numeric, Date, DateTime, Boolean, ForeignKey, UniqueConstraint, CheckConstraint
from app.extensions import db


class Campana(db.Model):
    __tablename__ = "campana"
    __table_args__ = (
        CheckConstraint("fecha_fin IS NULL OR fecha_fin >= fecha_inicio", name="CK_campana_fechas"),
        {"schema": "dbo"}
    )

    id_campana = db.Column(Integer, primary_key=True, autoincrement=True)
    id_plataforma = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=False)
    nombre = db.Column(String(150), nullable=False)
    id_segmento_objetivo = db.Column(Integer, ForeignKey("dbo.segmento_cliente.id_segmento"), nullable=True)
    id_producto_gancho = db.Column(Integer, ForeignKey("dbo.producto_carta.id_producto"), nullable=True)
    fecha_inicio = db.Column(Date, nullable=False)
    fecha_fin = db.Column(Date, nullable=True)
    meta_campaign_id = db.Column(String(100), nullable=True, unique=True)
    activa = db.Column(Boolean, nullable=False, default=True)

    # Relaciones
    plataforma = db.relationship("Plataforma", back_populates="campanas", lazy="joined")
    segmento_objetivo = db.relationship("SegmentoCliente", back_populates="campanas", lazy="joined")
    producto_gancho = db.relationship("ProductoCarta", back_populates="campanas_gancho", lazy="joined")
    publicaciones = db.relationship("Publicacion", back_populates="campana", lazy="select")
    anuncios = db.relationship("Anuncio", back_populates="campana", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_campana": self.id_campana,
            "id_plataforma": self.id_plataforma,
            "plataforma_codigo": self.plataforma.codigo if self.plataforma else None,
            "nombre": self.nombre,
            "id_segmento_objetivo": self.id_segmento_objetivo,
            "segmento_nombre": self.segmento_objetivo.nombre if self.segmento_objetivo else None,
            "id_producto_gancho": self.id_producto_gancho,
            "producto_gancho_nombre": self.producto_gancho.nombre if self.producto_gancho else None,
            "fecha_inicio": self.fecha_inicio.isoformat() if self.fecha_inicio else None,
            "fecha_fin": self.fecha_fin.isoformat() if self.fecha_fin else None,
            "meta_campaign_id": self.meta_campaign_id,
            "activa": self.activa,
        }


class Publicacion(db.Model):
    __tablename__ = "publicacion"
    __table_args__ = (
        UniqueConstraint("id_plataforma", "meta_post_id", name="UQ_publicacion_externa"),
        CheckConstraint("estado IN ('PROGRAMADA','PUBLICADA','ARCHIVADA')", name="CK_publicacion_estado"),
        {"schema": "dbo"}
    )

    id_publicacion = db.Column(Integer, primary_key=True, autoincrement=True)
    id_plataforma = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=False)
    id_campana = db.Column(Integer, ForeignKey("dbo.campana.id_campana"), nullable=True)
    meta_post_id = db.Column(String(150), nullable=False)
    texto = db.Column(String(2000), nullable=True)
    url_publicacion = db.Column(String(600), nullable=True)
    url_formulario = db.Column(String(600), nullable=True)
    fecha_publicacion = db.Column(DateTime, nullable=False)
    estado = db.Column(String(20), nullable=False, default="PUBLICADA")

    # Relaciones
    plataforma = db.relationship("Plataforma", back_populates="publicaciones", lazy="joined")
    campana = db.relationship("Campana", back_populates="publicaciones", lazy="joined")
    anuncios = db.relationship("Anuncio", back_populates="publicacion", lazy="select")
    metricas = db.relationship("MetricaPublicacionDiaria", back_populates="publicacion", lazy="select")
    interacciones = db.relationship("InteraccionPublicacion", back_populates="publicacion", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        latest_metrica = None
        if self.metricas:
            latest_metrica = max(
                self.metricas,
                key=lambda m: m.fecha_corte if m.fecha_corte else date.min,
                default=None,
            )

        reacciones = latest_metrica.total_reacciones if latest_metrica else None
        coms_meta = latest_metrica.total_comentarios if latest_metrica else None
        coms_capturados = (
            sum(
                1
                for i in self.interacciones
                if not (i.id_interaccion_externa and i.id_interaccion_externa.startswith("DEMO_"))
            )
            if self.interacciones
            else 0
        )

        return {
            "id_publicacion": self.id_publicacion,
            "id_plataforma": self.id_plataforma,
            "plataforma_codigo": self.plataforma.codigo if self.plataforma else None,
            "id_campana": self.id_campana,
            "campana_nombre": self.campana.nombre if self.campana else None,
            "meta_post_id": self.meta_post_id,
            "origen": "DEMO" if (self.meta_post_id and self.meta_post_id.startswith("DEMO_")) else "META_REAL",
            "texto": self.texto,
            "url_publicacion": self.url_publicacion,
            "url_formulario": self.url_formulario,
            "fecha_publicacion": self.fecha_publicacion.isoformat() if self.fecha_publicacion else None,
            "estado": self.estado,
            "total_reacciones": reacciones,
            "total_likes": reacciones,
            "total_comentarios": coms_meta,
            "comentarios_reportados_meta": coms_meta,
            "comentarios_capturados": coms_capturados,
        }


class Anuncio(db.Model):
    __tablename__ = "anuncio"
    __table_args__ = (
        CheckConstraint("fecha_fin IS NULL OR fecha_fin >= fecha_inicio", name="CK_anuncio_fecha"),
        {"schema": "dbo"}
    )

    id_anuncio = db.Column(Integer, primary_key=True, autoincrement=True)
    id_campana = db.Column(Integer, ForeignKey("dbo.campana.id_campana"), nullable=False)
    id_publicacion = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=True)
    meta_ad_id = db.Column(String(150), nullable=True, unique=True)
    nombre = db.Column(String(150), nullable=False)
    fecha_inicio = db.Column(DateTime, nullable=False)
    fecha_fin = db.Column(DateTime, nullable=True)

    # Relaciones
    campana = db.relationship("Campana", back_populates="anuncios", lazy="joined")
    publicacion = db.relationship("Publicacion", back_populates="anuncios", lazy="joined")
    gastos = db.relationship("GastoAnuncioDiario", back_populates="anuncio", lazy="select")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_anuncio": self.id_anuncio,
            "id_campana": self.id_campana,
            "campana_nombre": self.campana.nombre if self.campana else None,
            "id_publicacion": self.id_publicacion,
            "meta_ad_id": self.meta_ad_id,
            "nombre": self.nombre,
            "fecha_inicio": self.fecha_inicio.isoformat() if self.fecha_inicio else None,
            "fecha_fin": self.fecha_fin.isoformat() if self.fecha_fin else None,
        }


class GastoAnuncioDiario(db.Model):
    __tablename__ = "gasto_anuncio_diario"
    __table_args__ = (
        CheckConstraint("monto >= 0", name="CK_gasto_monto_pos"),
        {"schema": "dbo"}
    )

    id_gasto = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_anuncio = db.Column(Integer, ForeignKey("dbo.anuncio.id_anuncio"), nullable=True)
    id_campana = db.Column(Integer, ForeignKey("dbo.campana.id_campana"), nullable=True)
    id_plataforma = db.Column(Integer, ForeignKey("dbo.plataforma.id_plataforma"), nullable=True)
    fecha = db.Column(Date, nullable=False)
    monto = db.Column(Numeric(12, 2), nullable=False)
    moneda = db.Column(String(3), nullable=False, default="PEN")
    origen_dato = db.Column(String(30), nullable=False, default="SIMULADO_ACADEMICO")
    es_simulado = db.Column(Boolean, nullable=False, default=True)
    observacion = db.Column(String(250), nullable=True)
    fecha_creacion = db.Column(DateTime, nullable=False, default=datetime.utcnow)

    # Relaciones
    anuncio = db.relationship("Anuncio", back_populates="gastos", lazy="joined")
    campana = db.relationship("Campana", lazy="joined")
    plataforma = db.relationship("Plataforma", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_gasto": self.id_gasto,
            "id_anuncio": self.id_anuncio,
            "anuncio_nombre": self.anuncio.nombre if self.anuncio else None,
            "id_campana": self.id_campana,
            "campana_nombre": self.campana.nombre if self.campana else None,
            "id_plataforma": self.id_plataforma,
            "plataforma_codigo": self.plataforma.codigo if self.plataforma else None,
            "fecha": self.fecha.isoformat() if self.fecha else None,
            "monto": float(self.monto) if self.monto is not None else 0.0,
            "moneda": self.moneda,
            "origen_dato": self.origen_dato,
            "es_simulado": self.es_simulado,
            "observacion": self.observacion,
            "fecha_creacion": self.fecha_creacion.isoformat() if self.fecha_creacion else None,
        }


class MetricaPublicacionDiaria(db.Model):
    __tablename__ = "metrica_publicacion_diaria"
    __table_args__ = (
        UniqueConstraint("id_publicacion", "fecha_corte", name="UQ_metrica_publicacion_fecha"),
        {"schema": "dbo"}
    )

    id_metrica = db.Column(BigInteger, primary_key=True, autoincrement=True)
    id_publicacion = db.Column(Integer, ForeignKey("dbo.publicacion.id_publicacion"), nullable=False)
    fecha_corte = db.Column(Date, nullable=False)
    total_reacciones = db.Column(Integer, nullable=True)
    total_comentarios = db.Column(Integer, nullable=True)
    total_compartidos = db.Column(Integer, nullable=True)
    alcance = db.Column(Integer, nullable=True)
    impresiones = db.Column(Integer, nullable=True)
    fecha_obtencion = db.Column(DateTime, nullable=False, default=datetime.utcnow)

    # Relaciones
    publicacion = db.relationship("Publicacion", back_populates="metricas", lazy="joined")

    def to_dict(self) -> dict[str, Any]:
        return {
            "id_metrica": self.id_metrica,
            "id_publicacion": self.id_publicacion,
            "fecha_corte": self.fecha_corte.isoformat() if self.fecha_corte else None,
            "total_reacciones": self.total_reacciones,
            "total_comentarios": self.total_comentarios,
            "total_compartidos": self.total_compartidos,
            "alcance": self.alcance,
            "impresiones": self.impresiones,
            "fecha_obtencion": self.fecha_obtencion.isoformat() if self.fecha_obtencion else None,
        }
