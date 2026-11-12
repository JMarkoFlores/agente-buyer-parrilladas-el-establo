"""
Servicio para la lógica de negocio de BUYERS y prospectos.
"""
from typing import Any
from app.repositories.buyer_repo import BuyerRepository


def mask_external_ref(ref: str | None) -> str:
    """
    Enmascara la referencia externa sin exponer PII.
    Para tokens web conserva el prefijo WEB_ y oculta el centro.
    """
    if not ref:
        return ""
    if ref.startswith("WEB_"):
        token_part = ref[4:]
        return f"WEB_{token_part[:6]}***{token_part[-4:]}" if len(token_part) > 10 else ref
    if len(ref) > 8:
        return ref[:4] + "***" + ref[-4:]
    return ref


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

        item = buyer.to_dict()
        nombre_persona = (
            f"{buyer.persona.nombres} {buyer.persona.apellidos}".strip()
            if buyer.persona
            else None
        )
        nombre_usuario = nombre_persona or self.repo.get_nombre_publico(id_buyer)

        item["nombre_usuario"] = nombre_usuario
        item["nombre_usuario_fuente"] = (
            "PERSONA" if nombre_persona else ("RED_SOCIAL" if nombre_usuario else None)
        )
        item["referencia_externa_enmascarada"] = mask_external_ref(item["referencia_externa"])
        item["ultimas_interacciones"] = [
            {
                "id_interaccion": inter.id_interaccion,
                "texto": inter.texto,
                "tipo": inter.tipo,
                "fecha_interaccion": (
                    inter.fecha_interaccion.isoformat() if inter.fecha_interaccion else None
                ),
                "meta_post_id": inter.publicacion.meta_post_id if inter.publicacion else None,
                "url_publicacion": (
                    inter.publicacion.url_publicacion if inter.publicacion else None
                ),
            }
            for inter in self.repo.get_ultimas_interacciones(id_buyer)
        ]
        return item
