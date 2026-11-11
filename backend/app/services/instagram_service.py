"""
Servicio de negocio para la captación y sincronización de Instagram:
- Verificación del estado y cuenta en Meta Graph API.
- Sincronización idempotente de publicaciones (dbo.publicacion).
- Captación de comentarios y detección de BUYERS (dbo.interaccion_publicacion, dbo.buyer).
- Registro de métricas disponibles: likes y comentarios (dbo.metrica_publicacion_diaria).
- Auditoría de eventos y acciones del agente (dbo.evento_integracion, dbo.accion_agente).
"""
from __future__ import annotations

import logging
import re
from datetime import datetime, date, timezone
from typing import Any
from flask import current_app
from app.extensions import db
from app.integrations.meta_client import (
    MetaGraphClient,
    MetaClientError,
    MetaAuthError,
    MetaPermissionError,
    mask_token,
)
from app.repositories.instagram_repository import InstagramRepository

logger = logging.getLogger("instagram_service")

FORM_URL_REGEX = re.compile(
    r"(https?://[^\s]+(?:formulario|form|landing|menu|promocion|registro|carta)[^\s]*)",
    re.IGNORECASE,
)
GENERIC_URL_REGEX = re.compile(r"(https?://[^\s]+)", re.IGNORECASE)


def parse_meta_datetime(iso_str: str | None) -> datetime:
    """Parsea fecha ISO 8601 a datetime UTC ingenuo (naive) para SQL Server."""
    if not iso_str:
        return datetime.utcnow()
    try:
        clean = iso_str.replace("Z", "+00:00")
        dt = datetime.fromisoformat(clean)
        if dt.tzinfo is not None:
            dt = dt.astimezone(timezone.utc).replace(tzinfo=None)
        return dt
    except Exception:
        return datetime.utcnow()


def extract_form_url(text: str | None) -> str | None:
    """Extrae URL de formulario o landing page referenciada en el texto del post."""
    if not text:
        return None
    match = FORM_URL_REGEX.search(text)
    if match:
        return match.group(1).rstrip(".,;!?)")
    generic = GENERIC_URL_REGEX.search(text)
    if generic:
        url = generic.group(1).rstrip(".,;!?)")
        if "instagram.com" not in url and "facebook.com" not in url:
            return url
    return None


class InstagramService:
    """
    Coordinador de negocio para la captación de publicaciones, comentarios y métricas
    desde la cuenta de Instagram hacia la base de datos SQL Server 'buyer'.
    """

    def __init__(
        self,
        client: MetaGraphClient | None = None,
        repo: type[InstagramRepository] = InstagramRepository,
    ):
        self.repo = repo
        self._custom_client = client

    def _get_client(self) -> tuple[MetaGraphClient, str]:
        """
        Obtiene o inicializa el cliente Meta para Instagram.
        Si META_IG_ACCESS_TOKEN está vacío y META_IG_LOGIN_TYPE == 'FACEBOOK_LOGIN',
        reutiliza META_PAGE_ACCESS_TOKEN.
        Retorna (client, ig_account_id).
        """
        if self._custom_client is not None:
            ig_id = current_app.config.get("META_IG_ACCOUNT_ID", "").strip()
            return self._custom_client, ig_id

        ig_account_id = current_app.config.get("META_IG_ACCOUNT_ID", "").strip()
        ig_token = current_app.config.get("META_IG_ACCESS_TOKEN", "").strip()
        page_token = current_app.config.get("META_PAGE_ACCESS_TOKEN", "").strip()

        # En modo FACEBOOK_LOGIN se utiliza el Page Access Token si ig_token no está especificado
        effective_token = ig_token or page_token
        version = current_app.config.get("META_GRAPH_VERSION", "v27.0")
        timeout = current_app.config.get("META_HTTP_TIMEOUT", 20)

        client = MetaGraphClient(
            access_token=effective_token,
            api_version=version,
            timeout=timeout,
        )
        return client, ig_account_id

    def get_status(self) -> dict[str, Any]:
        """
        Diagnóstico del estado de la integración con Instagram.
        Verifica token, cuenta de Instagram conectada y capacidades activas.
        NUNCA expone credenciales en texto claro.
        """
        client, ig_account_id = self._get_client()
        version = current_app.config.get("META_GRAPH_VERSION", "v27.0")
        login_type = current_app.config.get("META_IG_LOGIN_TYPE", "FACEBOOK_LOGIN")

        ig_plat = self.repo.get_instagram_platform()
        db_configurada = ig_plat is not None

        if not ig_account_id:
            return {
                "conectado": False,
                "estado": "no_configurado",
                "mensaje": "META_IG_ACCOUNT_ID no configurado en el servidor.",
                "version_api": version,
                "login_type": login_type,
                "token_configurado": bool(client.access_token),
                "plataforma_db_encontrada": db_configurada,
                "capacidades": {
                    "lectura_publicaciones": False,
                    "lectura_comentarios": False,
                    "lectura_metricas": False,
                },
            }

        verify_result = client.verify_instagram_connection(ig_account_id)
        if not verify_result.get("conectado"):
            return {
                "conectado": False,
                "estado": "error_autenticacion",
                "mensaje": verify_result.get("motivo", "Fallo al verificar conexión con Instagram."),
                "version_api": version,
                "login_type": login_type,
                "ig_account_id": ig_account_id,
                "token_configurado": bool(client.access_token),
                "token_enmascarado": mask_token(client.access_token),
                "plataforma_db_encontrada": db_configurada,
                "capacidades": {
                    "lectura_publicaciones": False,
                    "lectura_comentarios": False,
                    "lectura_metricas": False,
                },
            }

        cuenta = verify_result.get("cuenta", {})
        return {
            "conectado": True,
            "estado": "conectado",
            "mensaje": "Conexión exitosa con Instagram Graph API.",
            "version_api": version,
            "login_type": login_type,
            "ig_account_id": ig_account_id,
            "cuenta": {
                "id": cuenta.get("id"),
                "name": cuenta.get("name"),
                "username": cuenta.get("username"),
            },
            "token_configurado": True,
            "token_enmascarado": mask_token(client.access_token),
            "plataforma_db_encontrada": db_configurada,
            "capacidades": {
                "lectura_publicaciones": True,
                "lectura_comentarios": True,
                "lectura_metricas": True,
            },
        }

    def sincronizar(self) -> dict[str, Any]:
        """
        Ejecuta la sincronización completa de Instagram:
        1. Sincroniza publicaciones/media (dbo.publicacion) con UPSERT seguro.
        2. Sincroniza comentarios (dbo.interaccion_publicacion).
        3. Identifica o reutiliza BUYERS (dbo.buyer) si hay identificador externo estable.
        4. Sincroniza métricas: likes y comments_count (dbo.metrica_publicacion_diaria).
        5. Registra auditoría (dbo.evento_integracion, dbo.accion_agente).
        """
        ig_plat = self.repo.get_instagram_platform()
        if not ig_plat:
            self.repo.record_accion_agente(
                accion="SINCRONIZAR_PUBLICACIONES",
                detalle="Plataforma INSTAGRAM no existe en dbo.plataforma.",
                resultado="FALLIDO",
            )
            db.session.commit()
            return {
                "success": False,
                "error": "La plataforma INSTAGRAM no está registrada en dbo.plataforma.",
            }

        client, ig_account_id = self._get_client()

        if not client.access_token or not ig_account_id:
            detalle_err = "Credenciales o ID de cuenta de Instagram no configurados en el servidor."
            self.repo.record_accion_agente(
                accion="SINCRONIZAR_PUBLICACIONES",
                detalle=detalle_err,
                resultado="FALLIDO",
            )
            db.session.commit()
            return {
                "success": False,
                "error": detalle_err,
            }

        # Actualizar meta_account_id en dbo.plataforma con el ID de Instagram
        self.repo.update_instagram_platform_meta_id(
            meta_account_id=ig_account_id,
            url_pagina="https://www.instagram.com/parrilladas.elestablo/",
        )

        # ---------------------------------------------------------------------
        # PASO 1: Sincronizar Publicaciones (Media)
        # ---------------------------------------------------------------------
        resumen_pub = {"nuevos": 0, "actualizados": 0, "omitidos": 0, "fallidos": 0}
        media_obtenida: list[dict[str, Any]] = []

        try:
            media_obtenida = client.get_instagram_media(ig_account_id)
        except (MetaAuthError, MetaPermissionError, MetaClientError) as exc:
            detalle_exc = f"Error al consultar media de Instagram en Meta: {str(exc)}"
            logger.error(detalle_exc)
            self.repo.record_accion_agente(
                accion="SINCRONIZAR_PUBLICACIONES",
                detalle=detalle_exc[:500],
                resultado="FALLIDO",
            )
            db.session.commit()
            return {
                "success": False,
                "error": str(exc),
                "fase_fallida": "publicaciones",
            }

        publicaciones_db: list[tuple[Any, dict[str, Any]]] = []

        for m_data in media_obtenida:
            media_id = m_data.get("id")
            if not media_id:
                resumen_pub["omitidos"] += 1
                continue

            caption = m_data.get("caption")
            permalink = m_data.get("permalink")
            url_form = extract_form_url(caption)
            fecha_pub = parse_meta_datetime(m_data.get("timestamp"))

            try:
                pub, creada = self.repo.upsert_publicacion(
                    id_plataforma=ig_plat.id_plataforma,
                    meta_post_id=media_id,
                    texto=caption,
                    url_publicacion=permalink,
                    url_formulario=url_form,
                    fecha_publicacion=fecha_pub,
                    id_campana=None,
                )
                publicaciones_db.append((pub, m_data))
                if creada:
                    resumen_pub["nuevos"] += 1
                else:
                    resumen_pub["actualizados"] += 1

                self.repo.record_evento_integracion(
                    id_evento_externo=media_id,
                    tipo="SYNC_INSTAGRAM_MEDIA",
                    estado="PROCESADO",
                )
            except Exception as exc:
                logger.error("Error al guardar publicación de Instagram %s: %s", media_id, str(exc))
                resumen_pub["fallidos"] += 1
                self.repo.record_evento_integracion(
                    id_evento_externo=media_id,
                    tipo="SYNC_INSTAGRAM_MEDIA",
                    estado="ERROR",
                    error_resumen=str(exc)[:300],
                )

        detalle_pub = (
            f"Publicaciones Instagram procesadas: {len(media_obtenida)}. "
            f"Nuevas: {resumen_pub['nuevos']}, Actualizadas: {resumen_pub['actualizados']}, "
            f"Fallidas: {resumen_pub['fallidos']}."
        )
        self.repo.record_accion_agente(
            accion="SINCRONIZAR_PUBLICACIONES",
            detalle=detalle_pub,
            resultado="EXITOSO" if resumen_pub["fallidos"] == 0 else "PENDIENTE",
        )

        # ---------------------------------------------------------------------
        # PASO 2: Sincronizar Comentarios y Detectar BUYERS
        # ---------------------------------------------------------------------
        resumen_com = {"nuevos": 0, "actualizados": 0, "omitidos": 0, "fallidos": 0}
        total_buyers_creados = 0
        total_buyers_reutilizados = 0

        for pub_tuple in publicaciones_db:
            pub, m_data = pub_tuple
            media_id = pub.meta_post_id
            comments_cnt = m_data.get("comments_count", 0)

            # Si la publicación reporta comentarios, consultarlos
            comments: list[dict[str, Any]] = []
            if comments_cnt and comments_cnt > 0:
                try:
                    comments = client.get_instagram_media_comments(media_id)
                except MetaClientError as exc:
                    logger.warning("No se pudieron consultar comentarios para media %s: %s", media_id, str(exc))
                    resumen_com["fallidos"] += 1
                    continue

            for c_data in comments:
                c_id = c_data.get("id")
                if not c_id:
                    resumen_com["omitidos"] += 1
                    continue

                c_text = c_data.get("text")
                c_date = parse_meta_datetime(c_data.get("timestamp"))

                # Extracción de usuario ('from' o 'username')
                from_user = c_data.get("from") or {}
                id_usuario_ext = from_user.get("id") if isinstance(from_user, dict) else None
                nombre_vis = (from_user.get("username") if isinstance(from_user, dict) else None) or c_data.get("username")

                id_buyer = None
                # Solo crear BUYER si existe un ID estable externo
                if id_usuario_ext and str(id_usuario_ext) != str(ig_account_id):
                    buyer, creado = self.repo.find_or_create_buyer(
                        id_plataforma_origen=ig_plat.id_plataforma,
                        referencia_externa=id_usuario_ext,
                        id_publicacion_origen=pub.id_publicacion,
                        fecha_primer_contacto=c_date,
                    )
                    if buyer:
                        id_buyer = buyer.id_buyer
                        if creado:
                            total_buyers_creados += 1
                        else:
                            total_buyers_reutilizados += 1

                try:
                    inter, creada = self.repo.upsert_interaccion(
                        id_publicacion=pub.id_publicacion,
                        id_interaccion_externa=c_id,
                        tipo="COMENTARIO",
                        id_usuario_externo=id_usuario_ext,
                        nombre_visible=nombre_vis,
                        texto=c_text,
                        fecha_interaccion=c_date,
                        id_buyer=id_buyer,
                    )
                    if creada:
                        resumen_com["nuevos"] += 1
                    else:
                        resumen_com["actualizados"] += 1

                    self.repo.record_evento_integracion(
                        id_evento_externo=c_id,
                        tipo="SYNC_COMENTARIOS_IG",
                        estado="PROCESADO",
                    )
                except Exception as exc:
                    logger.error("Error al registrar interacción Instagram %s: %s", c_id, str(exc))
                    resumen_com["fallidos"] += 1
                    self.repo.record_evento_integracion(
                        id_evento_externo=c_id,
                        tipo="SYNC_COMENTARIOS_IG",
                        estado="ERROR",
                        error_resumen=str(exc)[:300],
                    )

        detalle_com = (
            f"Comentarios Instagram procesados. Nuevos: {resumen_com['nuevos']}, "
            f"Actualizados: {resumen_com['actualizados']}, Fallidos: {resumen_com['fallidos']}. "
            f"BUYERS nuevos: {total_buyers_creados}, BUYERS reutilizados: {total_buyers_reutilizados}."
        )
        self.repo.record_accion_agente(
            accion="SINCRONIZAR_COMENTARIOS",
            detalle=detalle_com,
            resultado="EXITOSO" if resumen_com["fallidos"] == 0 else "PENDIENTE",
        )

        # ---------------------------------------------------------------------
        # PASO 3: Sincronizar Métricas Disponibles (Likes y Comments Count)
        # ---------------------------------------------------------------------
        resumen_met = {"nuevos": 0, "actualizados": 0, "omitidos": 0, "fallidos": 0}
        fecha_corte = date.today()

        for pub_tuple in publicaciones_db:
            pub, m_data = pub_tuple
            media_id = pub.meta_post_id

            total_reacciones = m_data.get("like_count")
            total_comentarios = m_data.get("comments_count")

            # Métricas avanzadas opcionales (alcance e impresiones)
            insights = client.get_instagram_media_insights(media_id)
            alcance = insights.get("alcance") if insights else None
            impresiones = insights.get("impresiones") if insights else None

            if total_reacciones is None and total_comentarios is None:
                resumen_met["omitidos"] += 1
                continue

            try:
                metrica, creada = self.repo.upsert_metrica_diaria(
                    id_publicacion=pub.id_publicacion,
                    fecha_corte=fecha_corte,
                    total_reacciones=total_reacciones,
                    total_comentarios=total_comentarios,
                    total_compartidos=None,
                    alcance=alcance,
                    impresiones=impresiones,
                )
                if creada:
                    resumen_met["nuevos"] += 1
                else:
                    resumen_met["actualizados"] += 1
            except Exception as exc:
                logger.error("Error al registrar métrica Instagram para media %s: %s", media_id, str(exc))
                resumen_met["fallidos"] += 1

        detalle_met = (
            f"Métricas diarias Instagram corte {fecha_corte.isoformat()}. Nuevas: {resumen_met['nuevos']}, "
            f"Actualizadas: {resumen_met['actualizados']}, Omitidas: {resumen_met['omitidos']}."
        )
        self.repo.record_accion_agente(
            accion="SINCRONIZAR_METRICAS",
            detalle=detalle_met,
            resultado="EXITOSO" if resumen_met["fallidos"] == 0 else "PENDIENTE",
        )

        # Confirmar en SQL Server
        db.session.commit()

        return {
            "success": True,
            "mensaje": "Sincronización con Instagram completada exitosamente.",
            "fecha_ejecucion": datetime.utcnow().isoformat(),
            "resumen": {
                "publicaciones": resumen_pub,
                "comentarios": resumen_com,
                "metricas": resumen_met,
                "buyers": {
                    "nuevos": total_buyers_creados,
                    "reutilizados": total_buyers_reutilizados,
                },
            },
        }

    # =========================================================================
    # Consultas para Endpoints REST de Instagram
    # =========================================================================

    def list_publicaciones(self, limit: int = 50, offset: int = 0) -> dict[str, Any]:
        """Consulta publicaciones de Instagram almacenadas en SQL Server."""
        items, total = self.repo.get_publicaciones(limit=limit, offset=offset)
        return {
            "total": total,
            "limit": limit,
            "offset": offset,
            "items": [p.to_dict() for p in items],
        }

    def list_comentarios(
        self,
        id_publicacion: int,
        limit: int = 100,
        offset: int = 0,
    ) -> dict[str, Any] | None:
        """Consulta comentarios de una publicación específica de Instagram."""
        pub = self.repo.get_publicacion_by_id(id_publicacion)
        if not pub:
            return None

        items, total = self.repo.get_comentarios_by_publicacion(id_publicacion, limit=limit, offset=offset)
        return {
            "id_publicacion": id_publicacion,
            "meta_post_id": pub.meta_post_id,
            "total_comentarios": total,
            "items": [c.to_dict() for c in items],
        }

    def list_metricas(
        self,
        id_publicacion: int | None = None,
        limit: int = 50,
        offset: int = 0,
    ) -> dict[str, Any]:
        """Consulta métricas diarias almacenadas para publicaciones de Instagram."""
        items, total = self.repo.get_metricas(id_publicacion=id_publicacion, limit=limit, offset=offset)
        return {
            "total": total,
            "limit": limit,
            "offset": offset,
            "items": [m.to_dict() for m in items],
        }
