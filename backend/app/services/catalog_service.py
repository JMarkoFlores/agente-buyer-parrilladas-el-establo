"""
Servicio para la consulta de catálogos y marketing:
- Plataformas
- Productos de la carta
- Campañas publicitarias
- Publicaciones en redes sociales
"""
from typing import Any
from app.repositories.plataforma_repo import PlataformaRepository
from app.repositories.producto_repo import ProductoRepository
from app.repositories.campana_repo import CampanaRepository
from app.repositories.publicacion_repo import PublicacionRepository


class CatalogService:
    def __init__(
        self,
        plat_repo: PlataformaRepository | None = None,
        prod_repo: ProductoRepository | None = None,
        camp_repo: CampanaRepository | None = None,
        pub_repo: PublicacionRepository | None = None,
    ):
        self.plat_repo = plat_repo or PlataformaRepository()
        self.prod_repo = prod_repo or ProductoRepository()
        self.camp_repo = camp_repo or CampanaRepository()
        self.pub_repo = pub_repo or PublicacionRepository()

    # Plataformas
    def list_plataformas(self, activa: bool | None = None) -> list[dict[str, Any]]:
        plataformas = self.plat_repo.get_all(activa=activa)
        return [p.to_dict() for p in plataformas]

    def get_plataforma(self, id_plataforma: int) -> dict[str, Any] | None:
        p = self.plat_repo.get_by_id(id_plataforma)
        return p.to_dict() if p else None

    # Productos
    def list_productos(self, categoria: str | None = None, activo: bool | None = None) -> list[dict[str, Any]]:
        productos = self.prod_repo.get_all(categoria=categoria, activo=activo)
        return [p.to_dict() for p in productos]

    def get_producto(self, id_producto: int) -> dict[str, Any] | None:
        p = self.prod_repo.get_by_id(id_producto)
        return p.to_dict() if p else None

    # Campañas
    def list_campanas(self, activa: bool | None = None, id_plataforma: int | None = None) -> list[dict[str, Any]]:
        campanas = self.camp_repo.get_all(activa=activa, id_plataforma=id_plataforma)
        return [c.to_dict() for c in campanas]

    def get_campana(self, id_campana: int) -> dict[str, Any] | None:
        c = self.camp_repo.get_by_id(id_campana)
        return c.to_dict() if c else None

    # Publicaciones
    def list_publicaciones(
        self,
        id_plataforma: int | None = None,
        id_campana: int | None = None,
        estado: str | None = None,
    ) -> list[dict[str, Any]]:
        publicaciones = self.pub_repo.get_all(
            id_plataforma=id_plataforma,
            id_campana=id_campana,
            estado=estado,
        )
        return [p.to_dict() for p in publicaciones]

    def get_publicacion(self, id_publicacion: int) -> dict[str, Any] | None:
        p = self.pub_repo.get_by_id(id_publicacion)
        return p.to_dict() if p else None
