"""
Módulo de configuración para la aplicación Flask y la conexión a SQL Server.
Utiliza SQLAlchemy URL.create para una construcción segura y normalizada de la cadena ODBC.
"""
import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy.engine import URL

# Cargar variables de entorno desde backend/.env o la raíz si existen
base_dir = Path(__file__).resolve().parent.parent
env_path = base_dir / ".env"
if env_path.exists():
    load_dotenv(dotenv_path=env_path)
else:
    load_dotenv()


def build_db_url(
    server: str | None = None,
    database: str | None = None,
    port: str | int | None = None,
    user: str | None = None,
    password: str | None = None,
    trusted_connection: bool = True,
    driver: str = "ODBC Driver 18 for SQL Server",
    trust_server_certificate: bool = True,
) -> URL:
    """
    Construye de manera segura el objeto URL de SQLAlchemy para el dialecto mssql+pyodbc.
    Evita problemas con espacios en blanco en el nombre del driver y caracteres especiales.
    """
    server = server or os.getenv("DB_SERVER", "localhost")
    database = database or os.getenv("DB_NAME", "buyer")
    raw_port = port if port is not None else os.getenv("DB_PORT", "")
    driver = driver or os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")

    # Parámetros del query ODBC
    query_params: dict[str, str] = {
        "driver": driver,
    }

    if trusted_connection:
        query_params["trusted_connection"] = "yes"
    else:
        query_params["trusted_connection"] = "no"

    # En desarrollo local suele ser necesario confiar en el certificado autofirmado
    if trust_server_certificate:
        query_params["TrustServerCertificate"] = "yes"
    else:
        query_params["TrustServerCertificate"] = "no"

    # Procesar puerto: solo incluirlo si fue explícitamente indicado y no está vacío
    parsed_port: int | None = None
    if raw_port:
        try:
            parsed_port = int(str(raw_port).strip())
        except ValueError:
            parsed_port = None

    return URL.create(
        drivername="mssql+pyodbc",
        username=user if not trusted_connection else None,
        password=password if not trusted_connection else None,
        host=server,
        port=parsed_port,
        database=database,
        query=query_params,
    )


def _to_bool(val: str | None, default: bool = False) -> bool:
    if val is None:
        return default
    return str(val).strip().lower() in ("true", "1", "t", "yes", "y", "si")


class BaseConfig:
    """Configuración base compartida entre entornos."""
    SECRET_KEY = os.getenv("SECRET_KEY", "establo-buyer-secret-key-default-2026")
    JSON_SORT_KEYS = False
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    
    # Datos de configuración SQL Server
    DB_SERVER = os.getenv("DB_SERVER", "localhost")
    DB_PORT = os.getenv("DB_PORT", "")
    DB_NAME = os.getenv("DB_NAME", "buyer")
    DB_USER = os.getenv("DB_USER", "")
    DB_PASSWORD = os.getenv("DB_PASSWORD", "")
    DB_DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
    DB_TRUSTED_CONNECTION = _to_bool(os.getenv("DB_TRUSTED_CONNECTION", "true"), default=True)
    DB_TRUST_SERVER_CERTIFICATE = _to_bool(os.getenv("DB_TRUST_SERVER_CERTIFICATE", "true"), default=True)

    # CORS
    raw_cors = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000,http://localhost:5173,http://127.0.0.1:5173")
    CORS_ORIGINS = [origin.strip() for origin in raw_cors.split(",") if origin.strip()]

    # Engine pool configuration
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,
        "pool_recycle": 1800,
    }

    # Meta Graph API (Facebook Pages & Instagram)
    META_GRAPH_VERSION = os.getenv("META_GRAPH_VERSION", "v21.0")
    META_APP_ID = os.getenv("META_APP_ID", "")
    META_APP_SECRET = os.getenv("META_APP_SECRET", "")
    META_PAGE_ID = os.getenv("META_PAGE_ID", "")
    META_PAGE_ACCESS_TOKEN = os.getenv("META_PAGE_ACCESS_TOKEN", "")
    META_VERIFY_TOKEN = os.getenv("META_VERIFY_TOKEN", "")
    META_IG_ACCOUNT_ID = os.getenv("META_IG_ACCOUNT_ID", "")
    META_IG_ACCESS_TOKEN = os.getenv("META_IG_ACCESS_TOKEN", "")
    META_IG_LOGIN_TYPE = os.getenv("META_IG_LOGIN_TYPE", "FACEBOOK_LOGIN")
    try:
        META_HTTP_TIMEOUT = int(os.getenv("META_HTTP_TIMEOUT", "20"))
    except ValueError:
        META_HTTP_TIMEOUT = 20

    # Token de administración local para proteger la sincronización
    ADMIN_API_KEY = os.getenv("ADMIN_API_KEY", "admin-establo-buyer-secret-2026")



class DevelopmentConfig(BaseConfig):
    """Configuración para entorno de desarrollo local."""
    DEBUG = True
    TESTING = False
    # En desarrollo local por defecto se confía en el certificado del servidor
    DB_TRUST_SERVER_CERTIFICATE = _to_bool(os.getenv("DB_TRUST_SERVER_CERTIFICATE", "true"), default=True)

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> URL:
        return build_db_url(
            server=self.DB_SERVER,
            database=self.DB_NAME,
            port=self.DB_PORT,
            user=self.DB_USER,
            password=self.DB_PASSWORD,
            trusted_connection=self.DB_TRUSTED_CONNECTION,
            driver=self.DB_DRIVER,
            trust_server_certificate=self.DB_TRUST_SERVER_CERTIFICATE,
        )


class TestingConfig(BaseConfig):
    """Configuración para pruebas automatizadas con pytest."""
    DEBUG = False
    TESTING = True
    DB_TRUST_SERVER_CERTIFICATE = True

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> URL:
        return build_db_url(
            server=self.DB_SERVER,
            database=self.DB_NAME,
            port=self.DB_PORT,
            user=self.DB_USER,
            password=self.DB_PASSWORD,
            trusted_connection=self.DB_TRUSTED_CONNECTION,
            driver=self.DB_DRIVER,
            trust_server_certificate=True,
        )


class ProductionConfig(BaseConfig):
    """Configuración para producción. Valida certificados y requiere autenticación segura."""
    DEBUG = False
    TESTING = False
    # En producción NO se confía ciegamente en certificados autofirmados a menos que se fuerce
    DB_TRUST_SERVER_CERTIFICATE = _to_bool(os.getenv("DB_TRUST_SERVER_CERTIFICATE", "false"), default=False)

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> URL:
        return build_db_url(
            server=self.DB_SERVER,
            database=self.DB_NAME,
            port=self.DB_PORT,
            user=self.DB_USER,
            password=self.DB_PASSWORD,
            trusted_connection=self.DB_TRUSTED_CONNECTION,
            driver=self.DB_DRIVER,
            trust_server_certificate=self.DB_TRUST_SERVER_CERTIFICATE,
        )


config_by_name = {
    "development": DevelopmentConfig,
    "testing": TestingConfig,
    "production": ProductionConfig,
}


def get_config(env_name: str | None = None) -> BaseConfig:
    """Retorna una instancia de configuración según el nombre del entorno."""
    env = (env_name or os.getenv("FLASK_ENV", "development")).lower()
    config_cls = config_by_name.get(env, DevelopmentConfig)
    return config_cls()
