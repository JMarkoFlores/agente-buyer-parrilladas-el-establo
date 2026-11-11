"""
Módulo de Clasificación Inteligente de Intención para Comentarios de Redes Sociales:
- Clasifica comentarios de prospectos en categorías de intención de negocio sin requerir APIs de pago.
- Maneja tildes, mayúsculas, signos de puntuación y variantes lingüísticas comunes en Perú/Hispanoamérica.
- Registra auditoría en dbo.accion_agente evitando duplicidades para comentarios que no cambiaron.
- No convierte automáticamente a un prospecto en LEAD.
"""
from __future__ import annotations

import logging
import re
import unicodedata
from datetime import datetime
from typing import Any
from sqlalchemy import desc

from app.extensions import db
from app.models.auditoria import AccionAgente
from app.models.persona import InteraccionPublicacion, Buyer

logger = logging.getLogger("interest_classifier")

# =============================================================================
# DEFINICIÓN DE CATEGORÍAS DE INTENCIÓN
# =============================================================================
CATEGORIA_CONSULTA_PRECIO = "CONSULTA_PRECIO"
CATEGORIA_INTERES_PRODUCTO = "INTERES_PRODUCTO"
CATEGORIA_CONSULTA_PROMOCION = "CONSULTA_PROMOCION"
CATEGORIA_CONSULTA_UBICACION = "CONSULTA_UBICACION"
CATEGORIA_CONSULTA_HORARIO = "CONSULTA_HORARIO"
CATEGORIA_CONSULTA_RESERVA = "CONSULTA_RESERVA"
CATEGORIA_ELOGIO = "ELOGIO"
CATEGORIA_AGRADECIMIENTO = "AGRADECIMIENTO"
CATEGORIA_EMOJI_POSITIVO = "EMOJI_POSITIVO"
CATEGORIA_SALUDO = "SALUDO"
CATEGORIA_INAPROPIADO = "INAPROPIADO"
CATEGORIA_SPAM = "SPAM"
CATEGORIA_DATOS_SENSIBLES = "DATOS_SENSIBLES"
CATEGORIA_OTRO = "OTRO"

CATEGORIAS_VALIDAS = [
    CATEGORIA_CONSULTA_PRECIO,
    CATEGORIA_INTERES_PRODUCTO,
    CATEGORIA_CONSULTA_PROMOCION,
    CATEGORIA_CONSULTA_UBICACION,
    CATEGORIA_CONSULTA_HORARIO,
    CATEGORIA_CONSULTA_RESERVA,
    CATEGORIA_ELOGIO,
    CATEGORIA_AGRADECIMIENTO,
    CATEGORIA_EMOJI_POSITIVO,
    CATEGORIA_SALUDO,
    CATEGORIA_INAPROPIADO,
    CATEGORIA_SPAM,
    CATEGORIA_DATOS_SENSIBLES,
    CATEGORIA_OTRO,
]


def normalizar_texto(texto: str | None) -> str:
    """
    Normaliza el texto para procesamiento:
    - Convierte a minúsculas.
    - Remueve diacríticos/acentos manteniendo caracteres alfanuméricos.
    - Colapsa espacios múltiples y elimina puntuación no informativa.
    """
    if not texto:
        return ""

    # Minúsculas y stripping
    t = texto.strip().lower()

    # Normalizar diacríticos (ej. á -> a, é -> e, etc.) pero conservar la ñ si es posible
    # Usar NFKD para separar letras de tildes
    nfkd = unicodedata.normalize("NFKD", t)
    # Conservamos letras y espacios, reemplazando caracteres combinados
    sin_tildes = "".join([c for c in nfkd if not unicodedata.combining(c)])

    # Reemplazar signos de interrogación, exclamación y puntuación por espacios
    limpio = re.sub(r"[¿?¡!.,;:()\-_/\\\"']+", " ", sin_tildes)
    # Colapsar espacios múltiples
    limpio = re.sub(r"\s+", " ", limpio).strip()

    return limpio


class InterestClassifier:
    """
    Clasificador heurístico basado en reglas de procesamiento de lenguaje natural
    para comentarios sobre Parrilladas El Establo.
    """

    # Patrones para filtros de seguridad y elegibilidad
    PATRONES_INAPROPIADO: list[re.Pattern] = [
        re.compile(r"\b(estafad?or(es|as)?|estafas?|rateros?|ladron(es)?|ladrona|raterio|mierda|carajo|puta|putos?|hdp|ctm|conchatumadre|asco|porqueria|asqueroso|basura|apestan|horrible|pesimo|malisimo|estafando|son\s+una\s+estafa)\b"),
        re.compile(r"\b(denuncia|indecopi|ladrones|porqueria\s+de\s+comida|comida\s+fria|pesima\s+atencion)\b"),
    ]

    PATRONES_DATOS_SENSIBLES: list[re.Pattern] = [
        re.compile(r"\b(?:\d[ -]*?){13,16}\b"),
        re.compile(r"\b(mi\s+clave|mi\s+password|mi\s+cvv|mi\s+tarjeta\s+es)\b"),
    ]

    PATRONES_SPAM: list[re.Pattern] = [
        re.compile(r"\b(t\.me/|wa\.me/|bit\.ly/|chat\.whatsapp\.com/|crypto|forex|inversiones\s+rentables)\b"),
    ]

    # Conjunto de emojis positivos reconocidos
    EMOJIS_POSITIVOS_SET = {"👍", "🔥", "🥩", "❤️", "👏", "😍", "🤤", "😋", "🙌", "👌", "💯", "🍻", "🥂", "🍖", "🍽️", "🐮", "🤠", "🍴", "✨", "🔝", "🎉"}

    # Reglas ordenadas por especificidad:
    # 1. Consulta de reserva (mesa, separar, agendar)
    # 2. Consulta de precio (cuanto cuesta, precio, valor)
    # 3. Consulta de promoción (promo, 2x1, descuento, oferta)
    # 4. Consulta de ubicación (donde, direccion, ubicacion, local)
    # 5. Consulta de horario (a que hora, atienden, horario, abren)
    # 6. Interés en producto (interes, me interesa, picaña, carne, cortes, carta)
    # 7. Elogio (buen asado, excelente servicio, deliciosa carne, lo mejor, espectacular)
    # 8. Agradecimiento (perfecto, gracias, muchas gracias, genial, listo, de acuerdo)
    # 9. Saludo (hola, buenas tardes, buenos dias)
    # 10. OTRO

    PATRONES: list[tuple[str, list[re.Pattern]]] = [
        (
            CATEGORIA_CONSULTA_RESERVA,
            [
                re.compile(r"\b(reser[bv][a-z]*|recer[bv][a-z]*|rezer[bv][a-z]*)\b"),
                re.compile(r"\b(separar\s+(una\s+)?mesa|mesa\s+para|reserva\s+de\s+mesa|disponibilidad\s+de\s+mesa)\b"),
                re.compile(r"\b(agendar|agenda|apartar\s+(una\s+)?mesa|quiero\s+(una\s+)?mesa)\b"),
                re.compile(r"\b(como|donde|don|kiero|quiero|deseo|puedo)\s+([a-z\s]*\s+)?(hago|hacer|ago|gestiono|gestionar|separo|separar|agendo|agendar)\s+([a-z\s]*\s+)?(reserva|mesa)\b"),
                re.compile(r"\b(como\s+puedo\s+hacer\s+(un\s+)?pedido|como\s+(hago|hacer|ago|realizo|realizar)\s+(un\s+|mi\s+)?pedido)\b"),
                re.compile(r"\b(quiero|kiero|deseo|puedo|como|donde|para)\s+pedir(\s+[a-z]+)*\b"),
                re.compile(r"\b(hacer|hago|realizar|realizo|tomar|toman)\s+(un\s+|el\s+|mi\s+)?pedido(s)?\b"),
                re.compile(r"\b(como|donde)\s+(pido|pedir)\b"),
                re.compile(r"\b(reservo\s+mi\s+pedido|reserva\s+de\s+pedido)\b"),
                re.compile(r"\b(quiero\s+hacer\s+mi\s+reserva|hacer\s+mi\s+reserva)\b"),
                re.compile(r"\b(delivery|a\s+domicilio|para\s+llevar)\b"),
            ],
        ),
        (
            CATEGORIA_CONSULTA_PRECIO,
            [
                re.compile(r"\b(precio|precios|cuanto\s+cuesta|cuanto\s+vale|cuanto\s+esta)\b"),
                re.compile(r"\b(costo|costos|valor|cotizar|cotizacion|tarifa|tarifas)\b"),
                re.compile(r"\b(a\s+cuanto|que\s+precio|cual\s+es\s+el\s+precio)\b"),
                re.compile(r"\b(lista\s+de\s+precios|carta\s+con\s+precios)\b"),
                re.compile(r"(s/\.?|\$|\bpen\b)\s*\d+"),
            ],
        ),
        (
            CATEGORIA_CONSULTA_PROMOCION,
            [
                re.compile(r"\b(promocion|promociones|promo|promos)\b"),
                re.compile(r"\b(descuento|descuentos|oferta|ofertas|rebaja)\b"),
                re.compile(r"\b(2x1|dos\s+por\s+uno|combo|combos)\b"),
                re.compile(r"\b(cumpleanos|cumple|aniversario)\b"),
                re.compile(r"\b(hay\s+oferta|tienen\s+promocion)\b"),
            ],
        ),
        (
            CATEGORIA_CONSULTA_UBICACION,
            [
                re.compile(r"\b(donde|dond|ubicacion|direccion|lugar)\b"),
                re.compile(r"\b(donde\s+(estan|queda|se\s+encuentran|se\s+ubican|queda\s+el\s+local))\b"),
                re.compile(r"\b(en\s+que\s+distrito|que\s+calle|como\s+llegar|mapa|croquis|referencia)\b"),
                re.compile(r"\b(direccion\s+exacta|tienen\s+local|sucursales|sede|sedes)\b"),
            ],
        ),
        (
            CATEGORIA_CONSULTA_HORARIO,
            [
                re.compile(r"\b(horario|horarios|hora|horas)\b"),
                re.compile(r"\b(a\s+que\s+hora\s+atienden|a\s+que\s+hora\s+abren|a\s+que\s+hora\s+cierran)\b"),
                re.compile(r"\b(atienden\s+hoy|abierto\s+hoy|abren\s+hoy|estan\s+abiertos)\b"),
                re.compile(r"\b(dias\s+de\s+atencion|dias\s+que\s+atienden|atienden\s+domingos)\b"),
                re.compile(r"\b(hora\s+de\s+cierre|hora\s+de\s+atencion)\b"),
                re.compile(r"\b(feriado|feriados|dias\s+feriados|en\s+feriados)\b"),
                re.compile(r"\b(atencion\s+en\s+feriados|atienden\s+en\s+feriados|abren\s+en\s+feriados)\b"),
                re.compile(r"\b(atencion\s+feriados|atienden\s+feriados|abren\s+feriados)\b"),
                re.compile(r"\bahi\s+atencion\s+en\s+feriados\b"),
            ],
        ),
        (
            CATEGORIA_ELOGIO,
            [
                re.compile(r"\b(buen\s+asado|buena\s+parrilla|buen\s+corte|buena\s+carne|buena\s+atencion|buen\s+servicio|excelente\s+servicio|excelente\s+atencion)\b"),
                re.compile(r"\b(buenazo|buenisimo|excelente|delicioso|espectacular|muy\s+rico|rico\s+asado|los\s+mejores|gran\s+lugar|recomendado|recomendadazo|felicitaciones|lo\s+maximo|me\s+encanta|pura\s+calidad)\b"),
                re.compile(r"\b(que\s+rico|que\s+delicia|que\s+bueno|se\s+ve\s+buenazo|se\s+ve\s+espectacular|lo\s+mejor\s+de)\b"),
                re.compile(r"\b(excelente\s+foto|buena\s+foto|buen\s+plato|buenisima)\b"),
            ],
        ),
        (
            CATEGORIA_INTERES_PRODUCTO,
            [
                re.compile(r"\b(interes|interesado|interesada|me\s+interesa|tengo\s+interes)\b"),
                re.compile(r"\b(info|informacion|detalles|mas\s+info|solicito\s+informacion)\b"),
                re.compile(r"\b(quiero\s+probar|se\s+ve\s+delicioso|delicioso|que\s+rico|antojo)\b"),
                re.compile(r"\b(picana|bife|parrillada|parrilla|asado|cortes|chorizo|anticucho)\b"),
                re.compile(r"\b(carta|menu|plato|platos|guarniciones)\b"),
                re.compile(r"\b(atienden\s+grupos|familiar|grupos\s+familiares)\b"),
            ],
        ),
        (
            CATEGORIA_AGRADECIMIENTO,
            [
                re.compile(r"\b(perfecto|muchas\s+gracias|mil\s+gracias|gracias|genial|listo|de\s+acuerdo|excelente\s+gracias|muchas\s+gracias\s+a\s+ustedes)\b"),
                re.compile(r"^(ok|vale|bien|entendido|gracias|perfecto|genial|listo|de\s+acuerdo)$"),
            ],
        ),
        (
            CATEGORIA_SALUDO,
            [
                re.compile(r"\b(hola|buenos\s+dias|buenas\s+tardes|buenas\s+noches|saludos|que\s+tal|hola\s+amigos)\b"),
            ],
        ),
    ]

    @classmethod
    def es_emoji_positivo(cls, texto: str | None) -> bool:
        """Determina si el texto está compuesto fundamentalmente por emojis positivos."""
        if not texto:
            return False
        clean = texto.strip()
        if not clean:
            return False
        # Eliminar signos de exclamación, interrogación, puntos y espacios
        solo_caracteres = re.sub(r"[\s¿?¡!.,;:()\-_/\\\"'#*]+", "", clean)
        if not solo_caracteres:
            return False
        # Comprobar si los caracteres restantes son en su gran mayoría emojis positivos
        emojis_encontrados = [c for c in solo_caracteres if c in cls.EMOJIS_POSITIVOS_SET]
        return len(emojis_encontrados) > 0 and len(emojis_encontrados) >= len(solo_caracteres) * 0.7

    @classmethod
    def clasificar(cls, texto: str | None) -> str:
        """
        Determina la intención predominante de un texto de comentario.
        Retorna una de las constantes CATEGORIA_* ('OTRO' si no coincide).
        """
        if not texto or not texto.strip():
            return CATEGORIA_OTRO

        raw_text = texto.strip()

        # 1. Filtro de seguridad: Contenido inapropiado / quejas severas / insultos
        normalizado = normalizar_texto(raw_text)
        for p in cls.PATRONES_INAPROPIADO:
            if p.search(normalizado):
                return CATEGORIA_INAPROPIADO

        # 2. Filtro de seguridad: Datos personales / sensibles
        for p in cls.PATRONES_DATOS_SENSIBLES:
            if p.search(raw_text):
                return CATEGORIA_DATOS_SENSIBLES

        # 3. Filtro de spam y enlaces externos no autorizados
        for p in cls.PATRONES_SPAM:
            if p.search(raw_text):
                return CATEGORIA_SPAM

        # Si incluye una URL desconocida que no sea del propio restaurante
        if re.search(r"https?://", raw_text, re.IGNORECASE):
            es_propio = "elestablo" in raw_text.lower() or "facebook.com" in raw_text.lower() or "instagram.com" in raw_text.lower()
            if not es_propio:
                return CATEGORIA_SPAM

        # 4. Emojis positivos (ej. 👍, 🔥, 🥩, 👍👍👍)
        if cls.es_emoji_positivo(raw_text):
            return CATEGORIA_EMOJI_POSITIVO

        if not normalizado or len(normalizado) < 2:
            return CATEGORIA_OTRO

        # 5. Evaluación de patrones de negocio (Comercial, Elogio, Agradecimiento, Saludo)
        for categoria, patrones in cls.PATRONES:
            for patron in patrones:
                if patron.search(normalizado):
                    return categoria

        return CATEGORIA_OTRO

    @classmethod
    def get_clasificacion_comentario(cls, id_interaccion_externa: str) -> str | None:
        """
        Consulta en dbo.accion_agente si el comentario ya cuenta con una clasificación registrada.
        """
        if not id_interaccion_externa:
            return None

        # Buscar en detalle si contiene el id de la interacción externa
        registro = (
            AccionAgente.query.filter(
                AccionAgente.nombre_agente == "AgenteBuyer",
                AccionAgente.accion == "CLASIFICAR_INTERES",
                AccionAgente.detalle.like(f"%{id_interaccion_externa}%"),
            )
            .order_by(desc(AccionAgente.fecha_ejecucion))
            .first()
        )

        if registro and registro.detalle:
            # Extraer categoría del detalle formato "Intencion: <CAT> | Comentario: <ID> | ..."
            match = re.search(r"Intenci[oó]n:\s*([A-Z_]+)", registro.detalle)
            if match:
                return match.group(1)
        return None

    @classmethod
    def registrar_clasificacion(
        cls,
        id_interaccion_externa: str,
        texto: str | None,
        id_buyer: int | None = None,
        forzar: bool = False,
    ) -> tuple[str, bool]:
        """
        Clasifica y persiste el resultado en dbo.accion_agente.
        Evita duplicar auditoría si el comentario ya fue clasificado previamente y no ha cambiado.
        Retorna (clasificacion, fue_registrado_nuevo).
        """
        clasificacion = cls.clasificar(texto)

        # Si ya está registrado y no se fuerza, no crear duplicado
        if not forzar:
            clasif_previa = cls.get_clasificacion_comentario(id_interaccion_externa)
            if clasif_previa is not None:
                return clasif_previa, False

        # Formatear detalle asegurando límite de 500 caracteres
        resumen_texto = (texto or "").strip()[:200]
        detalle = f"Intención: {clasificacion} | Comentario: {id_interaccion_externa} | Texto: {resumen_texto}"
        if len(detalle) > 500:
            detalle = detalle[:497] + "..."

        nueva_accion = AccionAgente(
            nombre_agente="AgenteBuyer",
            id_buyer=id_buyer,
            accion="CLASIFICAR_INTERES",
            detalle=detalle,
            resultado="EXITOSO",
            fecha_ejecucion=datetime.utcnow(),
        )
        db.session.add(nueva_accion)
        return clasificacion, True

    @classmethod
    def clasificar_interacciones_pendientes(cls, limite: int = 100) -> dict[str, Any]:
        """
        Clasifica comentarios que aún no cuenten con registro en dbo.accion_agente.
        Procesa hasta `limite` interacciones por ejecución.
        """
        interacciones = (
            InteraccionPublicacion.query.order_by(desc(InteraccionPublicacion.fecha_interaccion))
            .limit(limite)
            .all()
        )

        resumen = {
            "total_evaluados": len(interacciones),
            "nuevos_clasificados": 0,
            "omitidos_ya_clasificados": 0,
            "por_categoria": {cat: 0 for cat in CATEGORIAS_VALIDAS},
        }

        for inter in interacciones:
            categoria, nuevo = cls.registrar_clasificacion(
                id_interaccion_externa=inter.id_interaccion_externa,
                texto=inter.texto,
                id_buyer=inter.id_buyer,
                forzar=False,
            )
            resumen["por_categoria"][categoria] = resumen["por_categoria"].get(categoria, 0) + 1
            if nuevo:
                resumen["nuevos_clasificados"] += 1
            else:
                resumen["omitidos_ya_clasificados"] += 1

        db.session.commit()
        return resumen
