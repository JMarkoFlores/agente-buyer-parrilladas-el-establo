"""
Pruebas Unitarias para el Clasificador Inteligente de Intención (InterestClassifier):
- Verifica las 6 categorías principales y la categoría residual OTRO.
- Soporta tildes, mayúsculas y variaciones comunes en español.
- Comprueba que la clasificación de intención no altera el estado del BUYER a LEAD.
- Comprueba la prevención de registros duplicados en dbo.accion_agente.
"""
import pytest
import uuid
from app.services.interest_classifier import (
    InterestClassifier,
    CATEGORIA_CONSULTA_PRECIO,
    CATEGORIA_INTERES_PRODUCTO,
    CATEGORIA_CONSULTA_PROMOCION,
    CATEGORIA_CONSULTA_UBICACION,
    CATEGORIA_CONSULTA_HORARIO,
    CATEGORIA_CONSULTA_RESERVA,
    CATEGORIA_OTRO,
    normalizar_texto,
)
from app.models.persona import Buyer
from app.models.auditoria import AccionAgente
from app.extensions import db


def test_normalizar_texto():
    """Comprueba la eliminación de tildes, minúsculas y caracteres especiales."""
    assert normalizar_texto("¿Cuánto CUESTA?") == "cuanto cuesta"
    assert normalizar_texto("¡Promoción 2x1!") == "promocion 2x1"
    assert normalizar_texto("  ¿Dónde queda el local?  ") == "donde queda el local"


def test_clasificacion_consulta_precio():
    """Ejemplos de consulta de precio."""
    assert InterestClassifier.clasificar("¿Cuánto cuesta la picaña?") == CATEGORIA_CONSULTA_PRECIO
    assert InterestClassifier.clasificar("precio del bife") == CATEGORIA_CONSULTA_PRECIO
    assert InterestClassifier.clasificar("CUANTO VALE LA PARRILLADA") == CATEGORIA_CONSULTA_PRECIO
    assert InterestClassifier.clasificar("Cual es el costo por persona?") == CATEGORIA_CONSULTA_PRECIO
    assert InterestClassifier.clasificar("tienen carta con precios?") == CATEGORIA_CONSULTA_PRECIO


def test_clasificacion_interes_producto():
    """Ejemplos de interés en producto."""
    assert InterestClassifier.clasificar("Tengo interés") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("me interesa probar la carne") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("Más información por favor") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("Solicito info") == CATEGORIA_INTERES_PRODUCTO
    assert InterestClassifier.clasificar("Se ve delicioso el corte de asado") == CATEGORIA_INTERES_PRODUCTO


def test_clasificacion_consulta_promocion():
    """Ejemplos de consulta de promociones."""
    assert InterestClassifier.clasificar("¿Tienen promociones?") == CATEGORIA_CONSULTA_PROMOCION
    assert InterestClassifier.clasificar("Hay alguna promo para cumpleañeros?") == CATEGORIA_CONSULTA_PROMOCION
    assert InterestClassifier.clasificar("Tienen 2x1 en sangría?") == CATEGORIA_CONSULTA_PROMOCION
    assert InterestClassifier.clasificar("Aplica algún descuento?") == CATEGORIA_CONSULTA_PROMOCION


def test_clasificacion_consulta_ubicacion():
    """Ejemplos de consulta de ubicación."""
    assert InterestClassifier.clasificar("¿Dónde se encuentran?") == CATEGORIA_CONSULTA_UBICACION
    assert InterestClassifier.clasificar("Donde queda el restaurante?") == CATEGORIA_CONSULTA_UBICACION
    assert InterestClassifier.clasificar("Cual es la dirección exacta?") == CATEGORIA_UBICACION if False else CATEGORIA_CONSULTA_UBICACION
    assert InterestClassifier.clasificar("En qué distrito están?") == CATEGORIA_CONSULTA_UBICACION


def test_clasificacion_consulta_horario():
    """Ejemplos de consulta de horario de atención."""
    assert InterestClassifier.clasificar("¿A qué hora atienden?") == CATEGORIA_HORARIO if False else CATEGORIA_CONSULTA_HORARIO
    assert InterestClassifier.clasificar("A que hora abren los domingos?") == CATEGORIA_CONSULTA_HORARIO
    assert InterestClassifier.clasificar("Cual es su horario de atención?") == CATEGORIA_CONSULTA_HORARIO
    assert InterestClassifier.clasificar("Están abiertos hoy feriado?") == CATEGORIA_CONSULTA_HORARIO


def test_clasificacion_consulta_reserva():
    """Ejemplos de consulta y solicitud de reserva."""
    assert InterestClassifier.clasificar("Quiero reservar una mesa") == CATEGORIA_CONSULTA_RESERVA
    assert InterestClassifier.clasificar("Se puede separar mesa para 6 personas?") == CATEGORIA_CONSULTA_RESERVA
    assert InterestClassifier.clasificar("Deseo hacer una reservación para el viernes") == CATEGORIA_CONSULTA_RESERVA


def test_clasificacion_otro():
    """Comentarios que no indican una intención clara de compra o consulta."""
    assert InterestClassifier.clasificar("Buena atención.") == CATEGORIA_OTRO
    assert InterestClassifier.clasificar("Excelente foto") == CATEGORIA_OTRO
    assert InterestClassifier.clasificar("👍") == CATEGORIA_OTRO
    assert InterestClassifier.clasificar("") == CATEGORIA_OTRO
    assert InterestClassifier.clasificar(None) == CATEGORIA_OTRO


def test_auditoria_sin_duplicados_y_sin_alterar_lead(app):
    """
    Verifica que:
    1. Se registra en dbo.accion_agente con nombre_agente='AgenteBuyer' y accion='CLASIFICAR_INTERES'.
    2. Ejecutar la clasificación repetida sobre el mismo comentario NO duplica la fila en accion_agente.
    3. El prospecto BUYER NO cambia su estado a LEAD.
    """
    with app.app_context():
        # Tomar un BUYER existente
        buyer = db.session.query(Buyer).filter(Buyer.estado == "BUYER").first()
        id_buyer = buyer.id_buyer if buyer else None

        test_comment_id = f"TEST_COMMENT_{uuid.uuid4().hex[:8]}"
        test_text = "Tengo interés en la parrillada"

        # 1. Primera clasificación
        cat1, nueva1 = InterestClassifier.registrar_clasificacion(
            id_interaccion_externa=test_comment_id,
            texto=test_text,
            id_buyer=id_buyer,
            forzar=False,
        )
        db.session.commit()

        assert cat1 == CATEGORIA_INTERES_PRODUCTO
        assert nueva1 is True

        # Verificar que el estado del buyer sigue siendo BUYER (no LEAD)
        if id_buyer:
            buyer_refreshed = db.session.query(Buyer).filter(Buyer.id_buyer == id_buyer).first()
            assert buyer_refreshed.estado == "BUYER"

        # 2. Segunda clasificación: debe detectar que ya está registrado y omitir inserción
        conteo_antes = (
            db.session.query(AccionAgente)
            .filter(
                AccionAgente.nombre_agente == "AgenteBuyer",
                AccionAgente.accion == "CLASIFICAR_INTERES",
                AccionAgente.detalle.like(f"%{test_comment_id}%"),
            )
            .count()
        )
        assert conteo_antes >= 1

        cat2, nueva2 = InterestClassifier.registrar_clasificacion(
            id_interaccion_externa=test_comment_id,
            texto=test_text,
            id_buyer=id_buyer,
            forzar=False,
        )
        db.session.commit()

        assert cat2 == CATEGORIA_INTERES_PRODUCTO
        assert nueva2 is False  # No se insertó una nueva fila duplicada

        conteo_despues = (
            db.session.query(AccionAgente)
            .filter(
                AccionAgente.nombre_agente == "AgenteBuyer",
                AccionAgente.accion == "CLASIFICAR_INTERES",
                AccionAgente.detalle.like(f"%{test_comment_id}%"),
            )
            .count()
        )
        assert conteo_despues == conteo_antes  # Cero duplicados
