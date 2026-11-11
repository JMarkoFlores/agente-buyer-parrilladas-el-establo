"""
Cliente HTTP para Meta Graph API (Facebook Pages API).
Implementa gestión segura de tokens, timeouts, reintentos controlados,
paginación por cursores y registro de errores con sanitización estricta de credenciales.
"""
from __future__ import annotations

import logging
import re
import time
from typing import Any
import requests

logger = logging.getLogger("meta_client")
logging.getLogger("urllib3").setLevel(logging.WARNING)
logging.getLogger("requests").setLevel(logging.WARNING)


class MetaClientError(Exception):
    """Excepción base para errores del cliente Meta Graph API."""
    def __init__(self, message: str, status_code: int | None = None, error_data: dict[str, Any] | None = None):
        super().__init__(message)
        self.status_code = status_code
        self.error_data = error_data or {}


class MetaAuthError(MetaClientError):
    """Error de autenticación o token inválido/expirado (HTTP 401 o código OAuth 190)."""
    pass


class MetaPermissionError(MetaClientError):
    """Error de permisos insuficientes para la operación solicitada (HTTP 403 o error de permisos)."""
    pass


class MetaRateLimitError(MetaClientError):
    """Límite de tasa de llamadas alcanzado (HTTP 429 o códigos de limitación de Meta)."""
    pass


class MetaNotFoundError(MetaClientError):
    """Recurso no encontrado en Meta Graph API (HTTP 404)."""
    pass


class MetaAPIError(MetaClientError):
    """Error de API devuelto por Meta (HTTP 400 u otros errores del servidor)."""
    pass


def mask_token(token: str | None) -> str:
    """Oculta el token para logging seguro sin exponer credenciales."""
    if not token:
        return "[VACIO]"
    clean = token.strip()
    if len(clean) <= 8:
        return "***"
    return f"{clean[:4]}...{clean[-4:]}"


def sanitize_text(text: str, token: str | None = None) -> str:
    """Elimina tokens de URLs, mensajes y cadenas de error."""
    if not text:
        return ""
    sanitized = text
    if token and len(token) > 4:
        sanitized = sanitized.replace(token, "[REDACTED_TOKEN]")
    # Enmascarar patrones access_token=...
    sanitized = re.sub(r"access_token=[a-zA-Z0-9_\-\|\.\:]+", "access_token=[REDACTED]", sanitized)
    sanitized = re.sub(r"Bearer\s+[a-zA-Z0-9_\-\|\.\:]+", "Bearer [REDACTED]", sanitized)
    return sanitized


class MetaGraphClient:
    """
    Cliente para interactuar con Meta Graph API v21.0+.
    Soporta autenticación Bearer, reintentos exponenciales, paginación con cursores
    y sanitización rigurosa de credenciales.
    """

    BASE_URL = "https://graph.facebook.com"

    def __init__(
        self,
        access_token: str | None = None,
        page_id: str | None = None,
        api_version: str = "v21.0",
        timeout: int = 20,
        max_retries: int = 3,
        session: requests.Session | None = None,
    ):
        self.access_token = (access_token or "").strip()
        self.page_id = (page_id or "").strip()
        self.api_version = (api_version or "v21.0").strip()
        if not self.api_version.startswith("v"):
            self.api_version = f"v{self.api_version}"
        self.timeout = timeout
        self.max_retries = max_retries
        self.session = session or requests.Session()

    def _build_url(self, path: str) -> str:
        clean_path = path.lstrip("/")
        return f"{self.BASE_URL}/{self.api_version}/{clean_path}"

    def _request(
        self,
        method: str,
        path_or_url: str,
        params: dict[str, Any] | None = None,
        data: dict[str, Any] | None = None,
        headers: dict[str, str] | None = None,
        retry_count: int = 0,
    ) -> dict[str, Any]:
        """
        Ejecuta una petición HTTP a Meta Graph API gestionando autenticación,
        códigos de error y reintentos automáticos para fallos transitorios.
        """
        if path_or_url.startswith("http://") or path_or_url.startswith("https://"):
            url = path_or_url
        else:
            url = self._build_url(path_or_url)

        req_headers = {
            "Accept": "application/json",
            "User-Agent": "ParrilladasElEstablo-BuyerAgent/1.0",
        }
        if self.access_token:
            req_headers["Authorization"] = f"Bearer {self.access_token}"
        if headers:
            req_headers.update(headers)

        req_params = dict(params or {})

        masked_url = sanitize_text(url, self.access_token)
        logger.debug("Meta API %s %s (intento %d)", method, masked_url, retry_count + 1)

        try:
            response = self.session.request(
                method=method,
                url=url,
                params=req_params,
                json=data if data else None,
                headers=req_headers,
                timeout=self.timeout,
            )
        except requests.exceptions.Timeout as exc:
            logger.warning("Timeout al conectar con Meta Graph API en %s", masked_url)
            if retry_count < self.max_retries:
                time.sleep((2 ** retry_count) * 0.5)
                return self._request(method, path_or_url, params, data, headers, retry_count + 1)
            raise MetaClientError(f"Timeout al conectar con Meta Graph API tras {self.max_retries} intentos.") from exc
        except requests.exceptions.RequestException as exc:
            sanitized_exc = sanitize_text(str(exc), self.access_token)
            logger.error("Error de conexión de red con Meta Graph API: %s", sanitized_exc)
            if retry_count < self.max_retries:
                time.sleep((2 ** retry_count) * 0.5)
                return self._request(method, path_or_url, params, data, headers, retry_count + 1)
            raise MetaClientError(f"Error de red al conectar con Meta: {sanitized_exc}") from exc

        # Procesar respuesta JSON si está presente
        try:
            body = response.json()
        except ValueError:
            body = {"raw_text": sanitize_text(response.text, self.access_token)}

        # Procesar código de respuesta HTTP
        status = response.status_code

        if 200 <= status < 300:
            return body

        # Extraer detalles de error devueltos por Meta
        meta_error = body.get("error", {}) if isinstance(body, dict) else {}
        error_message = sanitize_text(meta_error.get("message", "Error desconocido de Meta"), self.access_token)
        error_code = meta_error.get("code")
        error_subcode = meta_error.get("error_subcode")
        error_type = meta_error.get("type", "")

        logger.warning(
            "Respuesta HTTP %d de Meta API: %s (code=%s, subcode=%s, type=%s)",
            status,
            error_message,
            error_code,
            error_subcode,
            error_type,
        )

        # 429 o Códigos de limitación de tasa Meta (4, 17, 32, 613)
        if status == 429 or error_code in (4, 17, 32, 613):
            if retry_count < self.max_retries:
                wait_sec = (2 ** retry_count) * 1.5
                logger.info("Límite de tasa alcanzado. Esperando %.1fs para reintentar...", wait_sec)
                time.sleep(wait_sec)
                return self._request(method, path_or_url, params, data, headers, retry_count + 1)
            raise MetaRateLimitError(
                f"Límite de tasa de Meta excedido: {error_message}",
                status_code=status,
                error_data=meta_error,
            )

        # 401 o Código 190 (OAuth / Token inválido o expirado)
        if status == 401 or error_code == 190:
            raise MetaAuthError(
                f"Error de autenticación con Meta Graph API: {error_message}",
                status_code=status,
                error_data=meta_error,
            )

        # 403 o Códigos de permisos insuficientes (10, 200, 298, etc.)
        if status == 403 or (status == 400 and error_code in (10, 200, 298, 803)):
            raise MetaPermissionError(
                f"Permisos insuficientes en Meta Graph API: {error_message}",
                status_code=status,
                error_data=meta_error,
            )

        # 404 Recurso no encontrado
        if status == 404:
            raise MetaNotFoundError(
                f"Recurso no encontrado en Meta: {error_message}",
                status_code=status,
                error_data=meta_error,
            )

        # Errores 5xx del servidor Meta (reintentables)
        if 500 <= status < 600:
            if retry_count < self.max_retries:
                wait_sec = (2 ** retry_count) * 1.0
                logger.info("Error transitorio %d de Meta. Esperando %.1fs...", status, wait_sec)
                time.sleep(wait_sec)
                return self._request(method, path_or_url, params, data, headers, retry_count + 1)
            raise MetaAPIError(
                f"Error interno del servidor de Meta (HTTP {status}): {error_message}",
                status_code=status,
                error_data=meta_error,
            )

        # Otros errores HTTP 400
        raise MetaAPIError(
            f"Error en solicitud a Meta Graph API (HTTP {status}): {error_message}",
            status_code=status,
            error_data=meta_error,
        )

    # =========================================================================
    # Métodos de negocio de Meta Pages API
    # =========================================================================

    def verify_connection(self) -> dict[str, Any]:
        """
        Verifica la validez de las credenciales llamando al endpoint /me y al de la página.
        Devuelve información estructurada sin exponer ningún token.
        """
        if not self.access_token:
            return {
                "conectado": False,
                "motivo": "Token de acceso META_PAGE_ACCESS_TOKEN no configurado.",
                "page_id": self.page_id or None,
            }

        # 1. Verificar identidad del token en /me
        try:
            me_info = self._request("GET", "me", params={"fields": "id,name"})
        except MetaAuthError as exc:
            return {
                "conectado": False,
                "motivo": f"Token inválido o expirado: {str(exc)}",
                "page_id": self.page_id or None,
            }
        except MetaClientError as exc:
            return {
                "conectado": False,
                "motivo": f"Error al verificar token: {str(exc)}",
                "page_id": self.page_id or None,
            }

        # 2. Si hay page_id especificado, verificar acceso a la página
        page_info = {}
        if self.page_id:
            try:
                page_info = self.get_page_info(self.page_id)
            except MetaPermissionError as exc:
                return {
                    "conectado": False,
                    "motivo": f"El token no tiene permisos para acceder a la página {self.page_id}: {str(exc)}",
                    "me": me_info,
                    "page_id": self.page_id,
                }
            except MetaClientError as exc:
                return {
                    "conectado": False,
                    "motivo": f"No se pudo consultar la página {self.page_id}: {str(exc)}",
                    "me": me_info,
                    "page_id": self.page_id,
                }

        return {
            "conectado": True,
            "api_version": self.api_version,
            "me": me_info,
            "pagina": page_info if page_info else me_info,
            "page_id": self.page_id or me_info.get("id"),
        }

    def get_page_info(self, page_id: str | None = None) -> dict[str, Any]:
        """Consulta información pública y administrativa de la Página de Facebook."""
        target_id = (page_id or self.page_id).strip()
        if not target_id:
            raise MetaClientError("Se requiere un Page ID para consultar información de la página.")

        fields = "id,name,link,is_published,category,fan_count,followers_count"
        return self._request("GET", target_id, params={"fields": fields})

    def debug_token(self, app_id: str | None = None, app_secret: str | None = None) -> dict[str, Any]:
        """
        Inspecciona el token configurado usando /debug_token si app_id/secret están disponibles,
        o mediante el endpoint /me/permissions.
        """
        if not self.access_token:
            return {"valido": False, "motivo": "Token no configurado."}

        # Si contamos con app_id y app_secret, podemos usar /debug_token
        if app_id and app_secret:
            app_token = f"{app_id}|{app_secret}"
            try:
                res = self._request(
                    "GET",
                    "debug_token",
                    params={"input_token": self.access_token, "access_token": app_token},
                )
                data = res.get("data", {})
                return {
                    "valido": data.get("is_valid", False),
                    "tipo": data.get("type"),
                    "scopes": data.get("scopes", []),
                    "expires_at": data.get("expires_at"),
                    "page_id": self.page_id,
                }
            except MetaClientError as exc:
                logger.warning("Fallo al consultar debug_token con app token: %s", str(exc))

        # Alternativa: consultar /me/permissions con el propio token
        try:
            perm_res = self._request("GET", "me/permissions")
            perm_data = perm_res.get("data", [])
            granted = [p.get("permission") for p in perm_data if p.get("status") == "granted"]
            declined = [p.get("permission") for p in perm_data if p.get("status") == "declined"]
            return {
                "valido": True,
                "permisos_concedidos": granted,
                "permisos_denegados": declined,
            }
        except MetaClientError as exc:
            return {
                "valido": False,
                "motivo": f"No se pudo inspeccionar permisos del token: {str(exc)}",
            }

    def get_published_posts(
        self,
        page_id: str | None = None,
        limit: int = 25,
        max_pages: int = 5,
    ) -> list[dict[str, Any]]:
        """
        Obtiene las publicaciones publicadas en la página (feed oficial).
        Campos solicitados: id, message, permalink_url, created_time, shares,
        comments.summary(true), reactions.summary(true).
        Implementa paginación automática usando cursores proporcionados por Meta.
        """
        target_id = (page_id or self.page_id).strip()
        if not target_id:
            raise MetaClientError("Se requiere un Page ID para consultar publicaciones.")

        fields = "id,message,story,permalink_url,created_time,shares,comments.summary(true),reactions.summary(true)"
        params: dict[str, Any] = {"fields": fields, "limit": min(limit, 100)}

        posts: list[dict[str, Any]] = []
        next_url_or_cursor: str | None = f"{target_id}/published_posts"
        current_page = 0

        while next_url_or_cursor and current_page < max_pages:
            current_page += 1
            if next_url_or_cursor.startswith("http"):
                res = self._request("GET", next_url_or_cursor)
            else:
                res = self._request("GET", next_url_or_cursor, params=params)

            data = res.get("data", [])
            posts.extend(data)

            # Paginación de Meta: paging.next o paging.cursors.after
            paging = res.get("paging", {})
            cursors = paging.get("cursors", {})
            after_cursor = cursors.get("after")

            next_url = paging.get("next")
            if next_url:
                next_url_or_cursor = next_url
                params = {}  # Los parámetros ya vienen incluidos en la URL devuelta por Meta
            else:
                next_url_or_cursor = None

        logger.info("Obtenidas %d publicaciones de Meta en %d página(s).", len(posts), current_page)
        return posts

    def get_post_comments(
        self,
        post_id: str,
        limit: int = 50,
        max_pages: int = 5,
    ) -> list[dict[str, Any]]:
        """
        Obtiene los comentarios de una publicación específica.
        Campos: id, message, created_time, from, parent.
        Paginación usando cursores de Meta.
        """
        clean_post_id = post_id.strip()
        if not clean_post_id:
            raise MetaClientError("Se requiere un Post ID para consultar comentarios.")

        fields = "id,message,created_time,from,parent"
        params: dict[str, Any] = {"fields": fields, "limit": min(limit, 100)}

        comments: list[dict[str, Any]] = []
        next_url_or_cursor: str | None = f"{clean_post_id}/comments"
        current_page = 0

        while next_url_or_cursor and current_page < max_pages:
            current_page += 1
            if next_url_or_cursor.startswith("http"):
                res = self._request("GET", next_url_or_cursor)
            else:
                res = self._request("GET", next_url_or_cursor, params=params)

            data = res.get("data", [])
            comments.extend(data)

            paging = res.get("paging", {})
            cursors = paging.get("cursors", {})
            after_cursor = cursors.get("after")

            next_url = paging.get("next")
            if next_url:
                next_url_or_cursor = next_url
                params = {}
            else:
                next_url_or_cursor = None

        logger.debug("Obtenidos %d comentarios para publicación %s.", len(comments), clean_post_id)
        return comments

    def get_post_insights(self, post_id: str) -> dict[str, int | None] | None:
        """
        Consulta métricas avanzadas (alcance e impresiones) para una publicación en /{post_id}/insights.
        Métricas: post_impressions, post_impressions_unique (alcance).
        Si Meta rechaza por falta de permisos o métricas no disponibles (ej. publicaciones orgánicas
        antiguas o falta de 'read_insights'), devuelve None sin abortar la sincronización.
        """
        clean_post_id = post_id.strip()
        try:
            res = self._request(
                "GET",
                f"{clean_post_id}/insights",
                params={"metric": "post_impressions,post_impressions_unique"},
            )
            data = res.get("data", [])
            result: dict[str, int | None] = {"alcance": None, "impresiones": None}

            for item in data:
                metric_name = item.get("name")
                values = item.get("values", [])
                if values and isinstance(values, list):
                    val = values[0].get("value")
                    if isinstance(val, (int, float)):
                        val_int = int(val)
                        if metric_name == "post_impressions":
                            result["impresiones"] = val_int
                        elif metric_name == "post_impressions_unique":
                            result["alcance"] = val_int

            return result
        except (MetaPermissionError, MetaAPIError) as exc:
            # Los permisos de insights pueden no estar concedidos a la aplicación.
            # Según los requerimientos, los campos no disponibles deben permanecer NULL (no cero).
            logger.info("Insights no disponibles para post %s: %s", clean_post_id, str(exc))
            return None
        except MetaClientError as exc:
            logger.warning("Error al consultar insights para post %s: %s", clean_post_id, str(exc))
            return None

    # =========================================================================
    # Métodos de negocio de Instagram Graph API
    # =========================================================================

    def verify_instagram_connection(self, ig_account_id: str | None = None) -> dict[str, Any]:
        """
        Verifica la validez de las credenciales para la cuenta de Instagram.
        Devuelve información estructurada sin exponer ningún token.
        """
        target_id = (ig_account_id or "").strip()
        if not target_id:
            return {
                "conectado": False,
                "motivo": "ID de cuenta de Instagram (META_IG_ACCOUNT_ID) no configurado.",
            }
        if not self.access_token:
            return {
                "conectado": False,
                "motivo": "Token de acceso para Instagram no configurado.",
                "ig_account_id": target_id,
            }

        try:
            account_info = self.get_instagram_account_info(target_id)
            return {
                "conectado": True,
                "api_version": self.api_version,
                "cuenta": account_info,
                "ig_account_id": target_id,
            }
        except MetaAuthError as exc:
            return {
                "conectado": False,
                "motivo": f"Token inválido o expirado para Instagram: {str(exc)}",
                "ig_account_id": target_id,
            }
        except MetaPermissionError as exc:
            return {
                "conectado": False,
                "motivo": f"Permisos insuficientes para acceder a la cuenta de Instagram {target_id}: {str(exc)}",
                "ig_account_id": target_id,
            }
        except MetaClientError as exc:
            return {
                "conectado": False,
                "motivo": f"No se pudo consultar la cuenta de Instagram {target_id}: {str(exc)}",
                "ig_account_id": target_id,
            }

    def get_instagram_account_info(self, ig_account_id: str) -> dict[str, Any]:
        """Consulta datos de la cuenta profesional / de negocios de Instagram."""
        target_id = ig_account_id.strip()
        if not target_id:
            raise MetaClientError("Se requiere un IG Account ID para consultar datos de la cuenta.")

        fields = "id,username,name,profile_picture_url,followers_count,media_count"
        return self._request("GET", target_id, params={"fields": fields})

    def get_instagram_media(
        self,
        ig_account_id: str,
        limit: int = 25,
        max_pages: int = 5,
    ) -> list[dict[str, Any]]:
        """
        Obtiene las publicaciones (media) de la cuenta de Instagram.
        Campos: id, caption, media_type, media_url, permalink, timestamp, like_count, comments_count.
        Paginación por cursores.
        """
        target_id = ig_account_id.strip()
        if not target_id:
            raise MetaClientError("Se requiere un IG Account ID para consultar publicaciones.")

        fields = "id,caption,media_type,media_url,permalink,timestamp,like_count,comments_count"
        params: dict[str, Any] = {"fields": fields, "limit": min(limit, 100)}

        media_items: list[dict[str, Any]] = []
        next_url_or_cursor: str | None = f"{target_id}/media"
        current_page = 0

        while next_url_or_cursor and current_page < max_pages:
            current_page += 1
            if next_url_or_cursor.startswith("http"):
                res = self._request("GET", next_url_or_cursor)
            else:
                res = self._request("GET", next_url_or_cursor, params=params)

            data = res.get("data", [])
            media_items.extend(data)

            paging = res.get("paging", {})
            next_url = paging.get("next")
            if next_url:
                next_url_or_cursor = next_url
                params = {}
            else:
                next_url_or_cursor = None

        logger.info("Obtenidas %d publicaciones de Instagram en %d página(s).", len(media_items), current_page)
        return media_items

    def get_instagram_media_comments(
        self,
        media_id: str,
        limit: int = 50,
        max_pages: int = 5,
    ) -> list[dict[str, Any]]:
        """
        Obtiene los comentarios de una publicación de Instagram.
        Campos: id, text, timestamp, username, from, like_count.
        """
        clean_media_id = media_id.strip()
        if not clean_media_id:
            raise MetaClientError("Se requiere un Media ID para consultar comentarios de Instagram.")

        fields = "id,text,timestamp,username,from,like_count"
        params: dict[str, Any] = {"fields": fields, "limit": min(limit, 100)}

        comments: list[dict[str, Any]] = []
        next_url_or_cursor: str | None = f"{clean_media_id}/comments"
        current_page = 0

        while next_url_or_cursor and current_page < max_pages:
            current_page += 1
            if next_url_or_cursor.startswith("http"):
                res = self._request("GET", next_url_or_cursor)
            else:
                res = self._request("GET", next_url_or_cursor, params=params)

            data = res.get("data", [])
            comments.extend(data)

            paging = res.get("paging", {})
            next_url = paging.get("next")
            if next_url:
                next_url_or_cursor = next_url
                params = {}
            else:
                next_url_or_cursor = None

        logger.debug("Obtenidos %d comentarios para media de Instagram %s.", len(comments), clean_media_id)
        return comments

    def get_instagram_media_insights(self, media_id: str) -> dict[str, int | None] | None:
        """
        Consulta métricas avanzadas (alcance, impresiones, guardados) para media de Instagram.
        Métricas compatibles: impressions, reach, saved.
        Si la API no las soporta o faltan permisos, retorna None de forma controlada.
        """
        clean_media_id = media_id.strip()
        try:
            res = self._request(
                "GET",
                f"{clean_media_id}/insights",
                params={"metric": "impressions,reach,saved"},
            )
            data = res.get("data", [])
            result: dict[str, int | None] = {"alcance": None, "impresiones": None, "guardados": None}

            for item in data:
                metric_name = item.get("name")
                values = item.get("values", [])
                if values and isinstance(values, list):
                    val = values[0].get("value")
                    if isinstance(val, (int, float)):
                        val_int = int(val)
                        if metric_name == "impressions":
                            result["impresiones"] = val_int
                        elif metric_name == "reach":
                            result["alcance"] = val_int
                        elif metric_name == "saved":
                            result["guardados"] = val_int

            return result
        except (MetaPermissionError, MetaAPIError) as exc:
            logger.info("Insights no disponibles para media IG %s: %s", clean_media_id, str(exc))
            return None
        except MetaClientError as exc:
            logger.warning("Error al consultar insights para media IG %s: %s", clean_media_id, str(exc))
            return None
