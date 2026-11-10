"""
Servicio para la lógica de negocio de BUYERS y prospectos.
"""
from typing import Any
from app.repositories.buyer_repo import BuyerRepository


class BuyerService:
    def __init__(self, repo: BuyerRepository | None = None):
        self.repo = repo or BuyerRepository()

    def list_buyers(
        self,
        estado: str | None = None,
        id_plataforma: int | None = None,
        page: int = 1,
        page_size: int = 20,
    ) -> dict[str, Any]:
        page = max(1, page)
        page_size = min(100, max(1, page_size))
        offset = (page - 1) * page_size

        items, total = self.repo.get_all(
            estado=estado,
            id_plataforma=id_plataforma,
            limit=page_size,
            offset=offset,
        )

        return {
            "total": total,
            "page": page,
            "page_size": page_size,
            "total_pages": (total + page_size - 1) // page_size if total > 0 else 0,
            "items": [buyer.to_dict() for buyer in items],
        }

    def get_buyer_by_id(self, id_buyer: int) -> dict[str, Any] | None:
        buyer = self.repo.get_by_id(id_buyer)
        if not buyer:
            return None
        return buyer.to_dict()
