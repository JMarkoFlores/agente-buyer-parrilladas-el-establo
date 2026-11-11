"""
Agente Coordinador de Sincronización y Captación de BUYERS:
- Coordina la ejecución de AgenteFacebook y AgenteInstagram.
- Consolida resultados de captación (publicaciones, comentarios, métricas, BUYERS).
- Controla errores de manera independiente: si una plataforma falla, la otra continúa.
- Evita ejecuciones concurrentes mediante bloqueo seguro.
- Ejecuta la clasificación inteligente de comentarios nuevos.
- Registra auditoría consolidada en dbo.accion_agente.
"""
from __future__ import annotations

import logging
import threading
from datetime import datetime
from typing import Any

from app.extensions import db
from app.agents.facebook_agent import AgenteFacebook
from app.agents.instagram_agent import AgenteInstagram
from app.services.interest_classifier import InterestClassifier
from app.models.auditoria import AccionAgente

logger = logging.getLogger("buyer_coordinator")


class SincronizacionEnCursoError(Exception):
    """Excepción lanzada cuando se intenta iniciar una sincronización mientras otra está en curso."""
    pass


class BuyerCoordinator:
    """
    Agente Coordinador que centraliza el flujo de sincronización multicanal
    de Facebook e Instagram para Parrilladas El Establo.
    """

    NOMBRE = "AgenteCoordinador"

    def __init__(
        self,
        fb_agent: AgenteFacebook | None = None,
        ig_agent: AgenteInstagram | None = None,
    ):
        self.fb_agent = fb_agent or AgenteFacebook()
        self.ig_agent = ig_agent or AgenteInstagram()
        self._lock = threading.Lock()
        self._is_running = False
        self._last_execution: dict[str, Any] | None = None

    @property
    def is_running(self) -> bool:
        """Indica si el coordinador se encuentra actualmente ejecutando una sincronización."""
        return self._is_running

    def get_status(self) -> dict[str, Any]:
        """
        Retorna el estado de salud y configuración de los agentes coordinados.
        """
        from flask import has_app_context
        fb_status: dict[str, Any] = {}
        ig_status: dict[str, Any] = {}
        if has_app_context():
            try:
                fb_status = self.fb_agent.get_status()
            except Exception as e:
                fb_status = {"conectado": False, "estado": "error", "mensaje": str(e)}
            try:
                ig_status = self.ig_agent.get_status()
            except Exception as e:
                ig_status = {"conectado": False, "estado": "error", "mensaje": str(e)}

        return {
            "coordinador": {
                "nombre": self.NOMBRE,
                "en_ejecucion": self._is_running,
                "ultima_ejecucion": self._last_execution,
            },
            "agente_facebook": {
                "conectado": fb_status.get("conectado", False),
                "estado": fb_status.get("estado", "desconocido"),
                "mensaje": fb_status.get("mensaje"),
                "capacidades": fb_status.get("capacidades", {}),
            },
            "agente_instagram": {
                "conectado": ig_status.get("conectado", False),
                "estado": ig_status.get("estado", "desconocido"),
                "mensaje": ig_status.get("mensaje"),
                "capacidades": ig_status.get("capacidades", {}),
            },
        }

    def sincronizar(
        self,
        plataforma: str = "todas",
        clasificar_comentarios: bool = True,
    ) -> dict[str, Any]:
        """
        Ejecuta la sincronización coordinada.
        :param plataforma: 'todas', 'facebook' o 'instagram'.
        :param clasificar_comentarios: si se debe ejecutar el clasificador de intención tras la ingesta.
        :return: Resumen consolidado con publicaciones, comentarios, métricas y buyers procesados.
        """
        # Control de concurrencia: evitar sincronizaciones simultáneas
        if not self._lock.acquire(blocking=False):
            logger.warning("[%s] Intento de sincronización simultánea bloqueado.", self.NOMBRE)
            raise SincronizacionEnCursoError("Existe otra sincronización en ejecución. Intente más tarde.")

        self._is_running = True
        inicio = datetime.utcnow()
        plataforma_norm = plataforma.strip().lower()

        resultado_fb: dict[str, Any] | None = None
        resultado_ig: dict[str, Any] | None = None
        error_fb: str | None = None
        error_ig: str | None = None

        try:
            # 1. Sincronizar Facebook si aplica
            if plataforma_norm in ("todas", "facebook", "fb"):
                try:
                    logger.info("[%s] Coordinando sincronización con Facebook...", self.NOMBRE)
                    resultado_fb = self.fb_agent.sincronizar()
                except Exception as exc:
                    error_fb = str(exc)
                    logger.error("[%s] Error en AgenteFacebook: %s", self.NOMBRE, error_fb, exc_info=True)
                    resultado_fb = {"success": False, "error": error_fb}

            # 2. Sincronizar Instagram si aplica (incluso si Facebook falló)
            if plataforma_norm in ("todas", "instagram", "ig"):
                try:
                    logger.info("[%s] Coordinando sincronización con Instagram...", self.NOMBRE)
                    resultado_ig = self.ig_agent.sincronizar()
                except Exception as exc:
                    error_ig = str(exc)
                    logger.error("[%s] Error en AgenteInstagram: %s", self.NOMBRE, error_ig, exc_info=True)
                    resultado_ig = {"success": False, "error": error_ig}

            # 3. Clasificación inteligente de comentarios nuevos si solicitado
            resumen_clasificacion: dict[str, Any] | None = None
            if clasificar_comentarios:
                try:
                    logger.info("[%s] Iniciando clasificación de intención de comentarios...", self.NOMBRE)
                    resumen_clasificacion = InterestClassifier.clasificar_interacciones_pendientes(limite=200)
                except Exception as exc:
                    logger.error("[%s] Error en InterestClassifier: %s", self.NOMBRE, str(exc), exc_info=True)
                    resumen_clasificacion = {"error": str(exc)}

            # 3.1 Evaluación y despacho de respuestas automáticas (no bloqueante)
            resumen_respuestas: dict[str, Any] | None = None
            try:
                from app.services.auto_reply_service import AutoReplyService
                auto_reply_service = AutoReplyService()
                resumen_respuestas = auto_reply_service.procesar_comentarios_nuevos()
                logger.info(
                    "[%s] Respuestas automáticas procesadas: Evaluados=%d, Generadas=%d, Despachadas=%d, Omitidos=%d",
                    self.NOMBRE,
                    resumen_respuestas.get("total_evaluados", 0),
                    resumen_respuestas.get("propuestas_generadas", 0),
                    resumen_respuestas.get("despachadas_cola", 0),
                    resumen_respuestas.get("omitidos", 0),
                )
            except Exception as exc:
                logger.warning("[%s] Error no bloqueante al evaluar respuestas automáticas: %s", self.NOMBRE, str(exc))

            # 4. Consolidación de métricas
            consolidado = self._consolidar_resultados(
                resultado_fb=resultado_fb,
                resultado_ig=resultado_ig,
                resumen_clasificacion=resumen_clasificacion,
                inicio=inicio,
                plataforma_solicitada=plataforma_norm,
            )
            consolidado["respuestas_automaticas"] = resumen_respuestas

            # 5. Auditoría del AgenteCoordinador
            self._registrar_auditoria_coordinador(consolidado)

            self._last_execution = {
                "fecha": consolidado["fecha_ejecucion"],
                "success": consolidado["success"],
                "resumen": consolidado["resumen_total"],
            }

            return consolidado

        finally:
            self._is_running = False
            self._lock.release()

    def _consolidar_resultados(
        self,
        resultado_fb: dict[str, Any] | None,
        resultado_ig: dict[str, Any] | None,
        resumen_clasificacion: dict[str, Any] | None,
        inicio: datetime,
        plataforma_solicitada: str,
    ) -> dict[str, Any]:
        """
        Combina los resúmenes de Facebook e Instagram en una estructura estandarizada.
        """
        fin = datetime.utcnow()
        duracion_segundos = round((fin - inicio).total_seconds(), 2)

        totales = {
            "publicaciones": {"nuevos": 0, "actualizados": 0, "fallidos": 0},
            "comentarios": {"nuevos": 0, "actualizados": 0, "fallidos": 0},
            "metricas": {"nuevos": 0, "actualizados": 0, "fallidos": 0},
            "buyers": {"nuevos": 0, "reutilizados": 0},
        }

        plataformas_exitosas: list[str] = []
        plataformas_fallidas: list[str] = []
        errores: list[str] = []

        # Sumar Facebook
        if resultado_fb:
            if resultado_fb.get("success"):
                plataformas_exitosas.append("FACEBOOK")
                res = resultado_fb.get("resumen", {})
                self._sumar_metricas(totales, res)
            else:
                plataformas_fallidas.append("FACEBOOK")
                errores.append(f"Facebook: {resultado_fb.get('error', 'Error desconocido')}")

        # Sumar Instagram
        if resultado_ig:
            if resultado_ig.get("success"):
                plataformas_exitosas.append("INSTAGRAM")
                res = resultado_ig.get("resumen", {})
                self._sumar_metricas(totales, res)
            else:
                plataformas_fallidas.append("INSTAGRAM")
                errores.append(f"Instagram: {resultado_ig.get('error', 'Error desconocido')}")

        # Determinar éxito global
        # Exitoso si al menos una plataforma solicitada completó exitosamente y no fallaron todas
        success_global = len(plataformas_exitosas) > 0

        estado = "EXITOSO"
        if not success_global:
            estado = "FALLIDO"
        elif len(plataformas_fallidas) > 0:
            estado = "PARCIAL"

        return {
            "success": success_global,
            "estado": estado,
            "coordinador": self.NOMBRE,
            "plataforma_solicitada": plataforma_solicitada,
            "plataformas_exitosas": plataformas_exitosas,
            "plataformas_fallidas": plataformas_fallidas,
            "errores": errores,
            "fecha_ejecucion": fin.isoformat(),
            "duracion_segundos": duracion_segundos,
            "resumen_total": totales,
            "detalle_facebook": resultado_fb,
            "detalle_instagram": resultado_ig,
            "clasificacion_comentarios": resumen_clasificacion,
        }

    @staticmethod
    def _sumar_metricas(totales: dict[str, Any], res: dict[str, Any]) -> None:
        """Suma contadores de publicaciones, comentarios, métricas y buyers."""
        for seccion in ("publicaciones", "comentarios", "metricas"):
            if seccion in res:
                totales[seccion]["nuevos"] += res[seccion].get("nuevos", 0)
                totales[seccion]["actualizados"] += res[seccion].get("actualizados", 0)
                totales[seccion]["fallidos"] += res[seccion].get("fallidos", 0)

        if "buyers" in res:
            totales["buyers"]["nuevos"] += res["buyers"].get("nuevos", 0)
            totales["buyers"]["reutilizados"] += res["buyers"].get("reutilizados", 0)

    def _registrar_auditoria_coordinador(self, consolidado: dict[str, Any]) -> None:
        """
        Registra la acción consolidada en dbo.accion_agente.
        """
        totales = consolidado["resumen_total"]
        detalle = (
            f"Sincronización {consolidado['plataforma_solicitada']}. "
            f"Pubs: +{totales['publicaciones']['nuevos']} (act: {totales['publicaciones']['actualizados']}), "
            f"Comentarios: +{totales['comentarios']['nuevos']}, "
            f"BUYERS: +{totales['buyers']['nuevos']} (reutil: {totales['buyers']['reutilizados']}), "
            f"Métricas: +{totales['metricas']['nuevos']}. "
            f"Éxito: {','.join(consolidado['plataformas_exitosas']) or 'Ninguna'}."
        )
        if consolidado["errores"]:
            detalle += f" Errores: {'; '.join(consolidado['errores'])}"

        # Restringir a 500 caracteres
        if len(detalle) > 500:
            detalle = detalle[:497] + "..."

        resultado_db = "EXITOSO" if consolidado["success"] else "FALLIDO"

        try:
            accion = AccionAgente(
                nombre_agente=self.NOMBRE,
                id_buyer=None,
                accion="SINCRONIZAR_COORDINADA",
                detalle=detalle,
                resultado=resultado_db,
                fecha_ejecucion=datetime.utcnow(),
            )
            db.session.add(accion)
            db.session.commit()
        except Exception as exc:
            db.session.rollback()
            logger.error("[%s] Error al registrar auditoría en dbo.accion_agente: %s", self.NOMBRE, str(exc))
