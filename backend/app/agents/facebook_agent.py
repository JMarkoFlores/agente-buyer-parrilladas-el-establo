"""
Agente Facebook:
Responsable de la captación y sincronización autónoma de datos de Facebook:
- Consulta publicaciones reales desde Meta Graph API.
- Consulta comentarios nuevos y respuestas disponibles.
- Actualiza métricas de reacciones y comentarios en dbo.metrica_publicacion_diaria.
- Relaciona interacciones con BUYERS cuando exista identidad autorizada.
- Registra auditoría en dbo.accion_agente y dbo.evento_integracion.
"""
from __future__ import annotations

import logging
from typing import Any
from app.services.facebook_service import FacebookService
from app.integrations.meta_client import MetaGraphClient
from app.repositories.facebook_repository import FacebookRepository

logger = logging.getLogger("agente_facebook")


class AgenteFacebook:
    """
    Agente inteligente especializado en la plataforma Facebook para Parrilladas El Establo.
    """

    NOMBRE = "AgenteFacebook"
    PLATAFORMA_CODIGO = "FACEBOOK"

    def __init__(
        self,
        service: FacebookService | None = None,
        client: MetaGraphClient | None = None,
        repo: type[FacebookRepository] = FacebookRepository,
    ):
        self.repo = repo
        self.service = service or FacebookService(client=client, repo=repo)

    def get_status(self) -> dict[str, Any]:
        """
        Diagnóstico del estado de la integración y credenciales con Facebook.
        """
        status = self.service.get_status()
        status["agente"] = self.NOMBRE
        return status

    def sincronizar(self) -> dict[str, Any]:
        """
        Ejecuta la sincronización completa de Facebook:
        1. Publicaciones
        2. Comentarios e interacciones
        3. Identificación de BUYERS
        4. Métricas agregadas y de alcance
        """
        logger.info("[%s] Iniciando ciclo de sincronización...", self.NOMBRE)
        resultado = self.service.sincronizar()
        resultado["agente"] = self.NOMBRE
        resultado["plataforma"] = self.PLATAFORMA_CODIGO
        return resultado

    def list_publicaciones(self, limit: int = 50, offset: int = 0) -> dict[str, Any]:
        return self.service.list_publicaciones(limit=limit, offset=offset)

    def list_comentarios(self, id_publicacion: int, limit: int = 100, offset: int = 0) -> dict[str, Any] | None:
        return self.service.list_comentarios(id_publicacion=id_publicacion, limit=limit, offset=offset)

    def list_metricas(self, id_publicacion: int | None = None, limit: int = 50, offset: int = 0) -> dict[str, Any]:
        return self.service.list_metricas(id_publicacion=id_publicacion, limit=limit, offset=offset)
