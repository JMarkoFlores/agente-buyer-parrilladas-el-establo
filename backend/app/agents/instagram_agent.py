"""
Agente Instagram:
Responsable de la captación y sincronización autónoma de datos de Instagram:
- Consulta publicaciones (media) reales desde Meta Graph API.
- Consulta comentarios nuevos.
- Obtiene cantidad de likes y comentarios.
- Registra nuevas interacciones en dbo.interaccion_publicacion.
- Relaciona comentarios con BUYERS identificables.
- Registra auditoría en dbo.accion_agente y dbo.evento_integracion.
"""
from __future__ import annotations

import logging
from typing import Any
from app.services.instagram_service import InstagramService
from app.integrations.meta_client import MetaGraphClient
from app.repositories.instagram_repository import InstagramRepository

logger = logging.getLogger("agente_instagram")


class AgenteInstagram:
    """
    Agente inteligente especializado en la plataforma Instagram para Parrilladas El Establo.
    """

    NOMBRE = "AgenteInstagram"
    PLATAFORMA_CODIGO = "INSTAGRAM"

    def __init__(
        self,
        service: InstagramService | None = None,
        client: MetaGraphClient | None = None,
        repo: type[InstagramRepository] = InstagramRepository,
    ):
        self.repo = repo
        self.service = service or InstagramService(client=client, repo=repo)

    def get_status(self) -> dict[str, Any]:
        """
        Diagnóstico del estado de la integración y credenciales con Instagram.
        """
        status = self.service.get_status()
        status["agente"] = self.NOMBRE
        return status

    def sincronizar(self) -> dict[str, Any]:
        """
        Ejecuta la sincronización completa de Instagram:
        1. Media / publicaciones
        2. Comentarios
        3. Identificación de BUYERS
        4. Métricas (likes y conteo de comentarios)
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
