"""
Configuración de fixtures para pytest.
"""
import sys
from pathlib import Path
import pytest

# Asegurar que el directorio backend está en el sys.path
backend_dir = Path(__file__).resolve().parent.parent
if str(backend_dir) not in sys.path:
    sys.path.insert(0, str(backend_dir))

from app import create_app
from app.config import TestingConfig
from sqlalchemy import or_


@pytest.fixture(scope="session")
def app():
    """Instancia de la aplicación Flask configurada para pruebas."""
    application = create_app(TestingConfig)
    return application


@pytest.fixture(scope="session")
def client(app):
    """Cliente de pruebas HTTP para ejecutar peticiones a los endpoints."""
    return app.test_client()


@pytest.fixture(autouse=True)
def prevent_db_contamination(app):
    """
    Control de aislamiento (Prompt 19):
    Asegura que ninguna ejecución de pruebas inserte o deje registros artificiales
    en la base de datos real. Limpia cualquier registro de test al finalizar cada caso.
    """
    yield
    with app.app_context():
        try:
            from app.extensions import db
            from app.models.persona import Persona, Buyer
            from app.models.conversion import FormularioCaptacion, LeadConversion, HistorialFases
            from app.models.web import VisitaWeb, VisitanteWeb, EventoWeb

            # Limpiar personas y conversiones generadas exclusivamente por tests (NUNCA tocar personas 1..5, 7)
            test_personas = db.session.query(Persona).filter(
                ~Persona.id_persona.in_([1, 2, 3, 4, 5, 7]),
                or_(
                    Persona.email.like("%@test.com"),
                    Persona.email.like("%@example.com"),
                    Persona.nombres.in_(["Valeria", "Test", "Prueba"]),
                )
            ).all()

            for p in test_personas:
                p_id = p.id_persona
                # Orden estricto de integridad referencial
                db.session.query(HistorialFases).filter_by(id_persona=p_id).delete(synchronize_session=False)
                db.session.query(LeadConversion).filter_by(id_persona=p_id).delete(synchronize_session=False)
                db.session.query(FormularioCaptacion).filter_by(id_persona=p_id).delete(synchronize_session=False)
                db.session.query(VisitaWeb).filter_by(id_buyer=p_id).update({"id_buyer": None}, synchronize_session=False)
                db.session.query(Buyer).filter_by(id_persona=p_id).delete(synchronize_session=False)
                db.session.query(VisitanteWeb).filter_by(id_persona=p_id).update({"id_persona": None}, synchronize_session=False)
                db.session.query(Persona).filter_by(id_persona=p_id).delete(synchronize_session=False)

            # Limpiar visitas de prueba generadas por tests (id_visita > 45 o utm_source de test)
            test_visitas = db.session.query(VisitaWeb).filter(
                or_(
                    VisitaWeb.id_visita > 45,
                    VisitaWeb.utm_source.in_(["test_source", "test"]),
                    VisitaWeb.utm_campaign.in_(["test_campaign", "test"]),
                )
            ).all()

            for v in test_visitas:
                v_id = v.id_visita
                db.session.query(EventoWeb).filter_by(id_visita=v_id).delete(synchronize_session=False)
                db.session.query(FormularioCaptacion).filter_by(id_visita=v_id).update({"id_visita": None}, synchronize_session=False)
                db.session.query(VisitaWeb).filter_by(id_visita=v_id).delete(synchronize_session=False)

            # Limpiar visitantes huérfanos creados durante la prueba
            db.session.query(VisitanteWeb).filter(
                VisitanteWeb.id_visitante > 24,
            ).delete(synchronize_session=False)

            db.session.commit()
        except Exception:
            db.session.rollback()
