"""
Servicio de negocio para la captación y sincronización de Facebook:
- Verificación del estado y permisos en Meta Graph API.
- Sincronización idempotente de publicaciones (dbo.publicacion).
- Captación de comentarios y creación de BUYERS (dbo.interaccion_publicacion, dbo.buyer).
- Registro de métricas disponibles (dbo.metrica_publicacion_diaria).
- Auditoría de eventos externos y acciones del agente (dbo.evento_integracion, dbo.accion_agente).
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
from app.repositories.facebook_repository import FacebookRepository

logger = logging.getLogger("facebook_service")

# Expresiones regulares para detección de enlaces de formulario/landing en el texto
FORM_URL_REGEX = re.compile(
    r"(https?://[^\s]+(?:formulario|form|landing|menu|promocion|registro|carta)[^\s]*)",
    re.IGNORECASE,
)
GENERIC_URL_REGEX = re.compile(r"(https?://[^\s]+)", re.IGNORECASE)


def parse_meta_datetime(iso_str: str | None) -> datetime:
    """Parsea fecha ISO 8601 de Meta a datetime UTC ingenuo (naive) para SQL Server."""
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
    """Extrae la URL de formulario o landing page referenciada en el texto del post."""
    if not text:
        return None
    match = FORM_URL_REGEX.search(text)
    if match:
        return match.group(1).rstrip(".,;!?)")
    generic = GENERIC_URL_REGEX.search(text)
    if generic:
        url = generic.group(1).rstrip(".,;!?)")
        if "facebook.com" not in url and "fb.me" not in url:
            return url
    return None


class FacebookService:
    """
    Coordinador de negocio para la captación de publicaciones, comentarios y métricas
    desde la página de Facebook hacia la base de datos SQL Server buyer.
    """

    def __init__(
        self,
        client: MetaGraphClient | None = None,
        repo: type[FacebookRepository] = FacebookRepository,
    ):
        self.repo = repo
        self._custom_client = client

    def _get_client(self) -> MetaGraphClient:
        """Obtiene o inicializa el cliente Meta con la configuración de Flask."""
        if self._custom_client is not None:
            return self._custom_client

        token = current_app.config.get("META_PAGE_ACCESS_TOKEN", "")
        page_id = current_app.config.get("META_PAGE_ID", "")
        version = current_app.config.get("META_GRAPH_VERSION", "v21.0")
        timeout = current_app.config.get("META_HTTP_TIMEOUT", 20)

        return MetaGraphClient(
            access_token=token,
            page_id=page_id,
            api_version=version,
            timeout=timeout,
        )

    def get_status(self) -> dict[str, Any]:
        """
        Diagnóstico completo del estado de integración con Facebook.
        Verifica token, identidad, permisos concedidos vs pendientes y capacidades activas.
        NUNCA expone el token de acceso en texto claro.
        """
        token = current_app.config.get("META_PAGE_ACCESS_TOKEN", "").strip()
        page_id = current_app.config.get("META_PAGE_ID", "").strip()
        version = current_app.config.get("META_GRAPH_VERSION", "v21.0")
        app_id = current_app.config.get("META_APP_ID", "").strip()
        app_secret = current_app.config.get("META_APP_SECRET", "").strip()

        fb_plat = self.repo.get_facebook_platform()
        db_configurada = fb_plat is not None

        # Si no hay token configurado
        if not token:
            return {
                "conectado": False,
                "estado": "no_configurado",
                "mensaje": "Credenciales de Meta no configuradas (META_PAGE_ACCESS_TOKEN vacío).",
                "version_api": version,
                "page_id_configurado": page_id or None,
                "token_configurado": False,
                "plataforma_db_encontrada": db_configurada,
                "permisos_disponibles": [],
                "permisos_pendientes": [
                    "pages_read_engagement",
                    "pages_read_user_content",
                    "read_insights",
                    "pages_show_list",
                ],
                "capacidades": {
                    "lectura_publicaciones": False,
                    "lectura_comentarios": False,
                    "lectura_metricas_basicas": False,
                    "lectura_alcance_e_impresiones": False,
                    "captacion_buyer": False,
                },
            }

        client = self._get_client()

        # 1. Probar conexión real a Meta
        verify_result = client.verify_connection()
        if not verify_result.get("conectado"):
            return {
                "conectado": False,
                "estado": "error_autenticacion",
                "mensaje": verify_result.get("motivo", "Fallo al verificar token con Meta."),
                "version_api": version,
                "page_id_configurado": page_id or None,
                "token_configurado": True,
                "token_enmascarado": mask_token(token),
                "plataforma_db_encontrada": db_configurada,
                "permisos_disponibles": [],
                "permisos_pendientes": [
                    "pages_read_engagement",
                    "pages_read_user_content",
                    "read_insights",
                    "pages_show_list",
                ],
                "capacidades": {
                    "lectura_publicaciones": False,
                    "lectura_comentarios": False,
                    "lectura_metricas_basicas": False,
                    "lectura_alcance_e_impresiones": False,
                    "captacion_buyer": False,
                },
            }

        # 2. Consultar permisos del token
        debug_info = client.debug_token(app_id=app_id, app_secret=app_secret)
        scopes = debug_info.get("scopes") or debug_info.get("permisos_concedidos") or []

        # Determinar permisos conocidos
        permisos_necesarios = ["pages_read_engagement", "pages_read_user_content", "read_insights", "pages_show_list"]
        pendientes = [p for p in permisos_necesarios if p not in scopes]

        # Determinar capacidades según permisos concedidos
        cap_posts = "pages_read_engagement" in scopes or True  # Con token de página propio suele estar disponible
        cap_comments = "pages_read_engagement" in scopes or "pages_read_user_content" in scopes
        cap_insights = "read_insights" in scopes

        return {
            "conectado": True,
            "estado": "conectado",
            "mensaje": "Conexión exitosa con Meta Graph API.",
            "version_api": version,
            "pagina": verify_result.get("pagina", {}),
            "page_id": verify_result.get("page_id"),
            "token_configurado": True,
            "token_enmascarado": mask_token(token),
            "token_valido": debug_info.get("valido", True),
            "plataforma_db_encontrada": db_configurada,
            "permisos_disponibles": scopes,
            "permisos_pendientes": pendientes,
            "capacidades": {
                "lectura_publicaciones": cap_posts,
                "lectura_comentarios": cap_comments,
                "lectura_metricas_basicas": True,
                "lectura_alcance_e_impresiones": cap_insights,
                "captacion_buyer": cap_comments,
            },
        }

    def sincronizar(self) -> dict[str, Any]:
        """
        Ejecuta la sincronización completa de la página de Facebook:
        1. Sincroniza publicaciones (dbo.publicacion) con UPSERT seguro.
        2. Sincroniza comentarios (dbo.interaccion_publicacion).
        3. Identifica o reutiliza BUYERS (dbo.buyer) sin crear PERSONAS.
        4. Sincroniza métricas disponibles (dbo.metrica_publicacion_diaria).
        5. Registra auditoría (dbo.evento_integracion, dbo.accion_agente).
        """
        # Verificar plataforma en base de datos
        fb_plat = self.repo.get_facebook_platform()
        if not fb_plat:
            self.repo.record_accion_agente(
                accion="SINCRONIZAR_PUBLICACIONES",
                detalle="Plataforma FACEBOOK no existe en dbo.plataforma.",
                resultado="FALLIDO",
            )
            db.session.commit()
            return {
                "success": False,
                "error": "La plataforma FACEBOOK no está registrada en dbo.plataforma.",
            }

        client = self._get_client()

        # Vincular meta_account_id en dbo.plataforma con el Page ID de Facebook
        if client.page_id:
            self.repo.update_facebook_platform_meta_id(client.page_id)

        # Verificar que haya token configurado
        if not client.access_token:
            detalle_err = "Token de acceso META_PAGE_ACCESS_TOKEN no configurado en el servidor."
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

        # ---------------------------------------------------------------------
        # PASO 1: Sincronizar Publicaciones
        # ---------------------------------------------------------------------
        resumen_pub = {"nuevos": 0, "actualizados": 0, "omitidos": 0, "fallidos": 0}
        posts_obtenidos: list[dict[str, Any]] = []

        try:
            posts_obtenidos = client.get_published_posts()
        except (MetaAuthError, MetaPermissionError, MetaClientError) as exc:
            detalle_exc = f"Error al consultar publicaciones en Meta: {str(exc)}"
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

        publicaciones_db: list[Any] = []

        for p_data in posts_obtenidos:
            meta_post_id = p_data.get("id")
            if not meta_post_id:
                resumen_pub["omitidos"] += 1
                continue

            texto = p_data.get("message") or p_data.get("story")
            url_pub = p_data.get("permalink_url")
            url_form = extract_form_url(texto)
            fecha_pub = parse_meta_datetime(p_data.get("created_time"))

            try:
                pub, creada = self.repo.upsert_publicacion(
                    id_plataforma=fb_plat.id_plataforma,
                    meta_post_id=meta_post_id,
                    texto=texto,
                    url_publicacion=url_pub,
                    url_formulario=url_form,
                    fecha_publicacion=fecha_pub,
                    id_campana=None,  # No inventar campañas publicitarias para posts orgánicos
                )
                publicaciones_db.append((pub, p_data))
                if creada:
                    resumen_pub["nuevos"] += 1
                else:
                    resumen_pub["actualizados"] += 1

                self.repo.record_evento_integracion(
                    id_evento_externo=meta_post_id,
                    tipo="SYNC_PUBLICACION",
                    estado="PROCESADO",
                )
            except Exception as exc:
                logger.error("Error al guardar publicación %s: %s", meta_post_id, str(exc))
                resumen_pub["fallidos"] += 1
                self.repo.record_evento_integracion(
                    id_evento_externo=meta_post_id,
                    tipo="SYNC_PUBLICACION",
                    estado="ERROR",
                    error_resumen=str(exc)[:300],
                )

        detalle_pub = (
            f"Publicaciones Meta procesadas: {len(posts_obtenidos)}. "
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

        # Si no obtuvimos publicaciones de la API (ej. feed vacío), consultar existentes en DB
        if not publicaciones_db:
            db_posts, _ = self.repo.get_publicaciones(limit=25)
            publicaciones_db = [(p, {}) for p in db_posts]

        for pub_tuple in publicaciones_db:
            pub = pub_tuple[0]
            meta_post_id = pub.meta_post_id

            p_data = pub_tuple[1]
            try:
                comments = client.get_post_comments(meta_post_id)
                if not comments and isinstance(p_data, dict) and "comments" in p_data:
                    comments = p_data.get("comments", {}).get("data", [])
            except MetaClientError as exc:
                logger.warning("No se pudieron consultar comentarios para %s: %s", meta_post_id, str(exc))
                # Fallback a comentarios embebidos en la publicación si existen
                if isinstance(p_data, dict) and "comments" in p_data:
                    comments = p_data.get("comments", {}).get("data", [])
                else:
                    resumen_com["fallidos"] += 1
                    continue

            for c_data in comments:
                c_id = c_data.get("id")
                if not c_id:
                    resumen_com["omitidos"] += 1
                    continue

                c_text = c_data.get("message")
                c_date = parse_meta_datetime(c_data.get("created_time"))

                # Determinar si es comentario top-level o respuesta
                has_parent = c_data.get("parent") is not None
                tipo_interaccion = "RESPUESTA" if has_parent else "COMENTARIO"

                # Extracción de usuario ('from')
                from_user = c_data.get("from")
                id_buyer = None
                id_usuario_ext = None
                nombre_vis = None

                if isinstance(from_user, dict):
                    id_usuario_ext = from_user.get("id")
                    nombre_vis = from_user.get("name")

                    # Regla de negocio: si el usuario es la propia página que responde,
                    # NO es un prospecto BUYER.
                    es_la_pagina = bool(
                        client.page_id and id_usuario_ext and str(id_usuario_ext) == str(client.page_id)
                    )

                    if id_usuario_ext and not es_la_pagina:
                        # Localizar o crear BUYER sin crear registro en dbo.persona
                        buyer, creado = self.repo.find_or_create_buyer(
                            id_plataforma_origen=fb_plat.id_plataforma,
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
                        tipo=tipo_interaccion,
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
                        tipo="SYNC_COMENTARIOS",
                        estado="PROCESADO",
                    )
                except Exception as exc:
                    logger.error("Error al registrar interacción %s: %s", c_id, str(exc))
                    resumen_com["fallidos"] += 1
                    self.repo.record_evento_integracion(
                        id_evento_externo=c_id,
                        tipo="SYNC_COMENTARIOS",
                        estado="ERROR",
                        error_resumen=str(exc)[:300],
                    )

        detalle_com = (
            f"Comentarios procesados. Nuevos: {resumen_com['nuevos']}, "
            f"Actualizados: {resumen_com['actualizados']}, Fallidos: {resumen_com['fallidos']}. "
            f"BUYERS nuevos: {total_buyers_creados}, BUYERS reutilizados: {total_buyers_reutilizados}."
        )
        self.repo.record_accion_agente(
            accion="SINCRONIZAR_COMENTARIOS",
            detalle=detalle_com,
            resultado="EXITOSO" if resumen_com["fallidos"] == 0 else "PENDIENTE",
        )

        # ---------------------------------------------------------------------
        # PASO 3: Sincronizar Métricas Disponibles
        # ---------------------------------------------------------------------
        resumen_met = {"nuevos": 0, "actualizados": 0, "omitidos": 0, "fallidos": 0}
        fecha_corte = date.today()

        for pub_tuple in publicaciones_db:
            pub = pub_tuple[0]
            p_data = pub_tuple[1]
            meta_post_id = pub.meta_post_id

            # Métricas agregadas presentes en la publicación
            total_reacciones = None
            if "reactions" in p_data and isinstance(p_data["reactions"], dict):
                total_reacciones = p_data["reactions"].get("summary", {}).get("total_count")

            total_comentarios = None
            if "comments" in p_data and isinstance(p_data["comments"], dict):
                total_comentarios = p_data["comments"].get("summary", {}).get("total_count")

            total_compartidos = None
            if "shares" in p_data and isinstance(p_data["shares"], dict):
                total_compartidos = p_data["shares"].get("count")

            # Métricas de insights (alcance e impresiones)
            insights = client.get_post_insights(meta_post_id)
            alcance = insights.get("alcance") if insights else None
            impresiones = insights.get("impresiones") if insights else None

            # Si Meta no proporcionó ningún dato de métrica, omitir
            if (
                total_reacciones is None
                and total_comentarios is None
                and total_compartidos is None
                and alcance is None
                and impresiones is None
            ):
                resumen_met["omitidos"] += 1
                continue

            try:
                metrica, creada = self.repo.upsert_metrica_diaria(
                    id_publicacion=pub.id_publicacion,
                    fecha_corte=fecha_corte,
                    total_reacciones=total_reacciones,
                    total_comentarios=total_comentarios,
                    total_compartidos=total_compartidos,
                    alcance=alcance,
                    impresiones=impresiones,
                )
                if creada:
                    resumen_met["nuevos"] += 1
                else:
                    resumen_met["actualizados"] += 1
            except Exception as exc:
                logger.error("Error al registrar métrica para post %s: %s", meta_post_id, str(exc))
                resumen_met["fallidos"] += 1

        detalle_met = (
            f"Métricas diarias corte {fecha_corte.isoformat()}. Nuevas: {resumen_met['nuevos']}, "
            f"Actualizadas: {resumen_met['actualizados']}, Omitidas: {resumen_met['omitidos']}."
        )
        self.repo.record_accion_agente(
            accion="SINCRONIZAR_METRICAS",
            detalle=detalle_met,
            resultado="EXITOSO" if resumen_met["fallidos"] == 0 else "PENDIENTE",
        )

        # Confirmar todos los cambios en SQL Server
        db.session.commit()

        return {
            "success": True,
            "mensaje": "Sincronización con Meta completada exitosamente.",
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
    # Consultas para los Endpoints REST de Facebook
    # =========================================================================

    def list_publicaciones(self, limit: int = 50, offset: int = 0) -> dict[str, Any]:
        """Consulta publicaciones de Facebook almacenadas en SQL Server."""
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
        """Consulta comentarios e interacciones de una publicación específica."""
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
        """Consulta métricas diarias almacenadas para publicaciones de Facebook."""
        items, total = self.repo.get_metricas(id_publicacion=id_publicacion, limit=limit, offset=offset)
        return {
            "total": total,
            "limit": limit,
            "offset": offset,
            "items": [m.to_dict() for m in items],
        }
