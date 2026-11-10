"""
Servicio para métricas y resúmenes ejecutivos del Agente BUYER.
"""
from typing import Any
from app.repositories.estadisticas_repo import EstadisticasRepository


class StatsService:
    def __init__(self, repo: EstadisticasRepository | None = None):
        self.repo = repo or EstadisticasRepository()

    def get_resumen(self) -> dict[str, Any]:
        return self.repo.get_resumen_general()
