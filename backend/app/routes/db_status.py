"""
Blueprint de comprobación de conexión y estado de SQL Server.
GET /api/db/status
Ejecuta una consulta real contra SQL Server y devuelve metadatos no sensibles.
"""
import logging
from flask import Blueprint, jsonify, current_app
from sqlalchemy import text
from app.extensions import db

logger = logging.getLogger(__name__)
db_status_bp = Blueprint("db_status", __name__)


@db_status_bp.route("/db/status", methods=["GET"])
def check_db_status():
    """
    Ejecuta una consulta SQL de diagnóstico real para verificar la conectividad con la base 'buyer'.
    Retorna información general no sensible y maneja errores sin filtrar contraseñas.
    """
    try:
        # Consulta de diagnóstico real
        query = text("""
            SELECT 
                DB_NAME() AS current_db,
                LEFT(@@VERSION, CHARINDEX('-', @@VERSION) - 1) AS server_edition,
                SYSUTCDATETIME() AS server_utc_time;
        """)
        
        tables_query = text("""
            SELECT COUNT(*) AS total_tablas
            FROM INFORMATION_SCHEMA.TABLES 
            WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo';
        """)

        with db.engine.connect() as conn:
            diag_row = conn.execute(query).fetchone()
            tables_row = conn.execute(tables_query).fetchone()

        db_name = diag_row[0] if diag_row else "desconocido"
        server_edition = diag_row[1].strip() if diag_row and diag_row[1] else "Microsoft SQL Server"
        server_time = diag_row[2].isoformat() if diag_row and diag_row[2] else None
        total_tables = tables_row[0] if tables_row else 0

        # Obtener configuración no sensible
        db_server = current_app.config.get("DB_SERVER", "localhost")
        db_driver = current_app.config.get("DB_DRIVER", "ODBC Driver 18 for SQL Server")
        trusted = current_app.config.get("DB_TRUSTED_CONNECTION", True)

        return jsonify({
            "status": "connected",
            "database": db_name,
            "server": db_server,
            "driver": db_driver,
            "auth_mode": "Windows Authentication (Trusted)" if trusted else "SQL Server Authentication",
            "server_edition": server_edition,
            "server_utc_time": server_time,
            "dbo_tables_count": total_tables,
            "expected_tables_count": 22,
            "schema_valid": total_tables == 22,
        }), 200

    except Exception as exc:
        logger.error("Error al conectar con SQL Server: %s", str(exc))
        # Ocultar secretos y responder con mensaje de error limpio
        return jsonify({
            "status": "error",
            "database": current_app.config.get("DB_NAME", "buyer"),
            "message": "No se pudo establecer conexión con Microsoft SQL Server.",
            "detail": "Verifique que el servicio SQL Server este iniciado y que las credenciales u ODBC driver esten correctamente configurados.",
        }), 503
