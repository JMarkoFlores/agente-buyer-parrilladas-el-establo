# ==============================================================================
# DOCKERFILE - BACKEND FLASK WSGI (GUNICORN) & STANDALONE SCHEDULER
# Agente Inteligente Multicanal para la Captación y Conversión de BUYERS
# Parrilladas El Establo
# ==============================================================================

FROM python:3.11-slim

# Evitar prompts interactivos y buffers de Python
ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

# Instalar dependencias de sistema y Microsoft ODBC Driver 18 for SQL Server
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg2 \
    ca-certificates \
    unixodbc \
    unixodbc-dev \
    gcc \
    g++ \
    && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft-prod.gpg \
    && curl -fsSL https://packages.microsoft.com/config/debian/12/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y --no-install-recommends msodbcsql18 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copiar el código fuente del backend y pruebas
COPY app/ ./app/
COPY tests/ ./tests/
COPY run.py run_scheduler.py ./

EXPOSE 5000

# Healthcheck usando endpoint oficial /api/health
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/api/health || exit 1

# Por defecto arranca el servidor WSGI Gunicorn para el servicio backend
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--timeout", "120", "--access-logfile", "-", "--error-logfile", "-", "run:app"]
