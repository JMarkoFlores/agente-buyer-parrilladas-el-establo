# 🤖 Agente Inteligente BUYER — Parrilladas El Establo

Backend en **Python + Flask** conectado a **Microsoft SQL Server** y a la **Meta Graph API (Facebook Pages)** para el sistema de captación, cualificación y trazabilidad del ciclo de vida del prospecto (BUYER) de **Parrilladas El Establo**.

![Python Version](https://img.shields.io/badge/Python-3.11%2B-blue?logo=python)
![Framework](https://img.shields.io/badge/Framework-Flask%203.x-lightgrey?logo=flask)
![Database](https://img.shields.io/badge/Database-SQL%20Server%202019%2F2022%2F2025-red?logo=microsoftsqlserver)
![Meta API](https://img.shields.io/badge/Integration-Meta%20Graph%20API%20v21.0-blue?logo=meta)
![ORM](https://img.shields.io/badge/ORM-SQLAlchemy%202.x-orange)
![Tests](https://img.shields.io/badge/Tests-Pytest%20Suite-green?logo=pytest)

---

## 📋 Tabla de Contenidos

1. [Descripción General](#1-descripción-general)
2. [Arquitectura del Proyecto](#2-arquitectura-del-proyecto)
3. [Requisitos Previos](#3-requisitos-previos)
4. [Instalación y Configuración](#4-instalación-y-configuración)
5. [Configuración de Base de Datos (SQL Server)](#5-configuración-de-base-de-datos-sql-server)
6. [Variables de Entorno](#6-variables-de-entorno)
7. [Ejecución del Servidor Flask](#7-ejecución-del-servidor-flask)
8. [Ejecución de Pruebas Automatizadas](#8-ejecución-de-pruebas-automatizadas)
9. [Catálogo de Endpoints de la API REST](#9-catálogo-de-endpoints-de-la-api-rest)
10. [Mapeo de Tablas en SQL Server](#10-mapeo-de-tablas-en-sql-server)
11. [Seguridad y Buenas Prácticas](#11-seguridad-y-buenas-prácticas)
12. [Guía para Subir a GitHub](#12-guía-para-subir-a-github)

---

## 1. Descripción General

El **Agente Inteligente BUYER** es una plataforma centralizada diseñada para consolidar las interacciones de los clientes de Parrilladas El Establo a través de múltiples canales:
- **Redes Sociales (Meta)**: Publicaciones, anuncios, comentarios y reacciones de Facebook e Instagram.
- **Canal Web**: Visitas, visitantes identificados mediante cookies y eventos de interacción en la Landing Page.
- **WhatsApp**: Hilos de conversación, mensajes entrantes y salientes.
- **Embudo de Conversión**: Trazabilidad del cambio de estado desde prospecto anónimo (`BUYER`) hacia cliente registrado con consentimiento explícito (`LEAD`).

---

## 2. Arquitectura del Proyecto

El backend implementa una arquitectura en capas desacopladas (Controlador / Servicio / Repositorio / ORM) con el patrón *Application Factory*:

```text
agente-buyer/
├── database/
│   ├── 01_CREAR_BUYER_FINAL.sql         # Script DDL: Creación del esquema 'buyer' (22 tablas normalizadas)
│   └── 02_LLENAR_BUYER_FINAL.sql        # Script DML: Datos semilla y catálogo inicial de prueba
├── backend/
│   ├── app/
│   │   ├── __init__.py                  # Application Factory (create_app) y registro de Blueprints
│   │   ├── config.py                    # Configuración modular (Base, Dev, Test, Prod) con URL.create
│   │   ├── extensions.py                # Instancias de SQLAlchemy y Flask-CORS
│   │   ├── agents/                      # Módulo de agentes inteligentes de cualificación
│   │   │   └── __init__.py
│   │   ├── integrations/                # Integraciones con APIs externas
│   │   │   ├── __init__.py
│   │   │   └── meta_client.py           # Cliente HTTP resiliente para Meta Graph API v21.0
│   │   ├── models/                      # Mapeo ORM SQLAlchemy de las 22 tablas existentes
│   │   │   ├── __init__.py              # Exportación centralizada de entidades
│   │   │   ├── auditoria.py             # evento_integracion, accion_agente
│   │   │   ├── catalogo.py              # plataforma, segmento_cliente, producto_carta
│   │   │   ├── conversion.py            # formulario_captacion, lead_conversion, historial_fases
│   │   │   ├── marketing.py             # campana, publicacion, anuncio, gasto, metricas
│   │   │   ├── persona.py               # persona, buyer, persona_red_social, interaccion
│   │   │   ├── web.py                   # visitante_web, visita_web, evento_web
│   │   │   └── whatsapp.py              # sesion_whatsapp, mensaje_whatsapp
│   │   ├── repositories/                # Capa de persistencia y consultas SQL Server
│   │   │   ├── __init__.py
│   │   │   ├── buyer_repo.py
│   │   │   ├── campana_repo.py
│   │   │   ├── estadisticas_repo.py
│   │   │   ├── facebook_repository.py   # Persistencia e idempotencia de Meta
│   │   │   ├── plataforma_repo.py
│   │   │   ├── producto_repo.py
│   │   │   └── publicacion_repo.py
│   │   ├── routes/                      # Controladores REST (Blueprints)
│   │   │   ├── __init__.py
│   │   │   ├── buyers.py                # Gestión y consulta de prospectos
│   │   │   ├── campanas.py              # Campañas publicitarias
│   │   │   ├── db_status.py             # Diagnóstico de conexión en vivo con SQL Server
│   │   │   ├── estadisticas.py          # Métricas analíticas y embudo
│   │   │   ├── facebook_routes.py       # Endpoints de Facebook y sincronización
│   │   │   ├── health.py                # Health check del servicio Flask
│   │   │   ├── plataformas.py           # Catálogo de plataformas
│   │   │   ├── productos.py             # Carta gastronómica
│   │   │   └── publicaciones.py         # Publicaciones multicanal
│   │   └── services/                    # Capa de lógica de negocio
│   │       ├── __init__.py
│   │       ├── buyer_service.py
│   │       ├── catalog_service.py
│   │       ├── facebook_service.py      # Orquestación de sincronización y BUYER creation
│   │       └── stats_service.py
│   ├── tests/                           # Suite de pruebas con Pytest
│   │   ├── __init__.py
│   │   ├── conftest.py                  # Fixtures de Flask y base de datos
│   │   ├── test_api_endpoints.py        # Pruebas de integración de la API REST
│   │   ├── test_db_status.py            # Validación de conectividad y esquema SQL Server
│   │   ├── test_facebook_integration.py # Pruebas de integración con Meta API
│   │   ├── test_facebook_unit.py        # Pruebas unitarias con mocks para Meta API
│   │   └── test_health.py               # Verificación básica de health check
│   ├── .env                             # Variables de entorno locales (ignorado por Git)
│   ├── .env.example                     # Plantilla versionada de variables de entorno
│   ├── requirements.txt                 # Dependencias Python del proyecto
│   └── run.py                           # Punto de entrada para el servidor local
├── .gitignore                           # Exclusión de archivos sensibles, temporales y .venv
└── README.md                            # Documentación técnica completa
```

---

## 3. Requisitos Previos

- **Python**: 3.11 o posterior (64-bit).
- **Microsoft SQL Server**: 2019, 2022 o 2025 (Local, Express o en Red).
- **Driver ODBC**: `ODBC Driver 18 for SQL Server` (o `ODBC Driver 17 for SQL Server`).
  - *Comprobar drivers instalados en Windows PowerShell:*
    ```powershell
    Get-ItemProperty "HKLM:\SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers"
    ```
- **Git**: 2.30 o superior para control de versiones.

---

## 4. Instalación y Configuración

### Paso 1: Clonar el repositorio
```bash
git clone https://github.com/<tu-usuario>/<tu-repositorio>.git
cd agente-buyer
```

### Paso 2: Crear y activar el entorno virtual (`.venv`)
- En **Windows (PowerShell)**:
  ```powershell
  python -m venv .venv
  .\.venv\Scripts\Activate.ps1
  ```
- En **Linux / macOS**:
  ```bash
  python3 -m venv .venv
  source .venv/bin/activate
  ```

### Paso 3: Instalar dependencias
```bash
pip install -r backend/requirements.txt
```

---

## 5. Configuración de Base de Datos (SQL Server)

1. Abra **SQL Server Management Studio (SSMS)** o **Azure Data Studio**.
2. Conéctese a su instancia de SQL Server.
3. Ejecute en orden los scripts ubicados en la carpeta `database/`:
   1. `database/01_CREAR_BUYER_FINAL.sql`: Crea la base de datos `buyer`, esquemas y las 22 tablas con sus llaves primarias, foráneas, índices y restricciones `CHECK`.
   2. `database/02_LLENAR_BUYER_FINAL.sql`: Inserta los catálogos base (plataformas, cartas gastronómicas, segmentos de cliente, campañas iniciales).

---

## 6. Variables de Entorno

Cree el archivo `backend/.env` copiando la plantilla `backend/.env.example`:

- En **Windows PowerShell**:
  ```powershell
  Copy-Item backend\.env.example backend\.env
  ```
- En **Linux / macOS**:
  ```bash
  cp backend/.env.example backend/.env
  ```

### Configuración de `backend/.env`:

```ini
# ==============================================================================
# CONFIGURACIÓN GENERAL DE FLASK
# ==============================================================================
FLASK_ENV=development
FLASK_PORT=5000
SECRET_KEY=dev-secret-key-establo-buyer-2026

# ==============================================================================
# CONEXIÓN A MICROSOFT SQL SERVER
# ==============================================================================
DB_SERVER=localhost
# DB_PORT: Dejar vacío si usa Named Pipes / Shared Memory. Si usa TCP/IP, coloque 1433.
DB_PORT=
DB_NAME=buyer
DB_USER=
DB_PASSWORD=
# true para Autenticación de Windows integrada; false para usuario sa / SQL Auth
DB_TRUSTED_CONNECTION=true
DB_DRIVER=ODBC Driver 18 for SQL Server
DB_TRUST_SERVER_CERTIFICATE=true

# Seguridad CORS (URLs frontend autorizadas)
CORS_ORIGINS=http://localhost:3000,http://127.0.0.1:3000,http://localhost:5173,http://127.0.0.1:5173

# ==============================================================================
# INTEGRACIÓN META GRAPH API (FACEBOOK PAGES)
# ==============================================================================
META_GRAPH_VERSION=v21.0
META_APP_ID=
META_APP_SECRET=
META_PAGE_ID=
META_PAGE_ACCESS_TOKEN=
META_VERIFY_TOKEN=
META_HTTP_TIMEOUT=20

# Token local para autorizar la sincronización manual vía /api/facebook/sincronizar
ADMIN_API_KEY=admin-establo-buyer-secret-2026
```

---

## 7. Ejecución del Servidor Flask

Para iniciar el servidor de desarrollo:

- En **Windows PowerShell**:
  ```powershell
  .\.venv\Scripts\python.exe backend\run.py
  ```
- En **Linux / macOS**:
  ```bash
  python backend/run.py
  ```

El servidor quedará disponible en:
```text
http://127.0.0.1:5000
```

---

## 8. Ejecución de Pruebas Automatizadas

El proyecto cuenta con una suite completa de pruebas unitarias y de integración desarrolladas con `pytest`:

```powershell
# Ejecutar todas las pruebas
pytest backend/tests -v

# Ejecutar únicamente las pruebas unitarias de Meta/Facebook (con mocks sin tocar BD)
pytest backend/tests/test_facebook_unit.py -v

# Ejecutar pruebas de conectividad de BD y health check
pytest backend/tests/test_health.py backend/tests/test_db_status.py -v
```

---

## 9. Catálogo de Endpoints de la API REST

Todos los endpoints retornan respuestas en formato estándar `application/json`.

### 9.1 Diagnóstico y Estado
| Método | Endpoint | Descripción |
|---|---|---|
| `GET` | `/api/health` | Verifica que el servidor Flask esté levantado. |
| `GET` | `/api/db/status` | Valida en vivo la conectividad con SQL Server y la existencia de las 22 tablas. |

### 9.2 Catálogo y Negocio
| Método | Endpoint | Parámetros Opcionales | Descripción |
|---|---|---|---|
| `GET` | `/api/plataformas` | `?activa=true\|false` | Canales (`FACEBOOK`, `INSTAGRAM`, `LANDING_PAGE`, `WHATSAPP`). |
| `GET` | `/api/plataformas/<id>` | — | Detalle de plataforma por ID. |
| `GET` | `/api/productos` | `?categoria=COMIDA\|BEBIDA\|POSTRE&activo=true` | Carta gastronómica del restaurante. |
| `GET` | `/api/productos/<id>` | — | Detalle de producto por ID. |
| `GET` | `/api/campanas` | `?activa=true&id_plataforma=1` | Campañas de marketing activas e históricas. |
| `GET` | `/api/campanas/<id>` | — | Detalle de campaña por ID. |
| `GET` | `/api/publicaciones` | `?id_plataforma=1&estado=PUBLICADA` | Publicaciones en redes sociales y web. |
| `GET` | `/api/publicaciones/<id>` | — | Detalle de publicación por ID. |
| `GET` | `/api/buyers` | `?estado=BUYER&id_plataforma=1&page=1&page_size=20` | Listado paginado de prospectos captados. |
| `GET` | `/api/buyers/<id>` | — | Detalle de buyer con interacciones y conversiones. |
| `GET` | `/api/estadisticas/resumen` | — | Consolidado analítico del embudo, canales y gastos en PEN. |

### 9.3 Integración con Facebook (Meta Graph API)
| Método | Endpoint | Autenticación | Descripción |
|---|---|---|---|
| `GET` | `/api/facebook/status` | Pública | Comprueba el estado de conexión con Meta Graph API y los permisos del token. |
| `POST` | `/api/facebook/sincronizar` | `X-Admin-Token` o `Bearer` | Sincroniza publicaciones, comentarios, métricas y prospectos hacia SQL Server. |
| `GET` | `/api/facebook/publicaciones` | Pública (`?limit=50&offset=0`) | Publicaciones de Facebook guardadas en la BD. |
| `GET` | `/api/facebook/publicaciones/<id>/comentarios` | Pública (`?limit=100&offset=0`) | Comentarios e interacciones de un post. |
| `GET` | `/api/facebook/metricas` | Pública (`?id_publicacion=1`) | Histórico de métricas diarias de posts. |

#### Ejemplo de sincronización manual de Facebook:
```bash
curl -X POST http://localhost:5000/api/facebook/sincronizar \
  -H "X-Admin-Token: admin-establo-buyer-secret-2026"
```

---

## 10. Mapeo de Tablas en SQL Server

El sistema opera sobre **22 tablas normalizadas** creadas por `database/01_CREAR_BUYER_FINAL.sql`:

| Dominio | Tablas Mapeadas | Módulo ORM |
|---|---|---|
| **Catálogo** | `plataforma`, `segmento_cliente`, `producto_carta` | `app/models/catalogo.py` |
| **Marketing** | `campana`, `publicacion`, `anuncio`, `gasto_anuncio_diario`, `metrica_publicacion_diaria` | `app/models/marketing.py` |
| **Personas y Buyers** | `persona`, `buyer`, `persona_red_social`, `interaccion_publicacion` | `app/models/persona.py` |
| **Canal Web** | `visitante_web`, `visita_web`, `evento_web` | `app/models/web.py` |
| **Canal WhatsApp** | `sesion_whatsapp`, `mensaje_whatsapp` | `app/models/whatsapp.py` |
| **Conversión** | `formulario_captacion`, `lead_conversion`, `historial_fases` | `app/models/conversion.py` |
| **Auditoría** | `evento_integracion`, `accion_agente` | `app/models/auditoria.py` |

---

## 11. Seguridad y Buenas Prácticas

- **Cero Credenciales en Código**: Contraseñas, claves de administración y tokens de Meta se configuran exclusivamente en variables de entorno (`.env`), el cual se encuentra estrictamente ignorado por `.gitignore`.
- **Enmascaramiento de Tokens**: Las funciones de log y las respuestas de error ofuscan automáticamente los tokens de Meta (`EAAB...xyz` -> `EAAB****xyz`).
- **Consultas Parametrizadas**: Todas las consultas SQL se realizan a través de SQLAlchemy ORM y sentencias seguras contra inyección SQL.
- **Idempotencia y Deduplicación**: Las llamadas de sincronización registran los identificadores externos (`wamid`, `meta_post_id`, `id_interaccion_externa`) en `evento_integracion` para evitar duplicidad de prospectos o métricas.
- **Protección de Datos Personales**: Los usuarios que comentan en redes se capturan como `BUYER` anónimo; no se crean registros en `dbo.persona` hasta que exista consentimiento explícito mediante formulario o conversión a `LEAD`.

---

## 12. Guía para Subir a GitHub

Siga estos pasos para publicar este proyecto en un nuevo repositorio de GitHub:

### Paso 1: Crear el repositorio en GitHub
1. Inicie sesión en [GitHub](https://github.com).
2. Haga clic en **New repository** (o **Nuevo repositorio**).
3. Nombre el repositorio (ejemplo: `agente-buyer`).
4. Seleccione **Public** o **Private**.
5. **No** marque las casillas de inicializar con `README`, `.gitignore` o `License` (ya están creados y configurados en este proyecto).
6. Haga clic en **Create repository**.

### Paso 2: Vincular y subir desde su terminal local

Abra su terminal (PowerShell o Bash) en la raíz del proyecto (`agente-buyer`):

```powershell
# 1. Asegúrese de estar en la rama principal
git branch -M main

# 2. Agregar todos los archivos al área de preparación (stage)
git add .

# 3. Verificar que .env y .venv NO aparezcan en verde (deben estar ignorados)
git status

# 4. Crear el commit inicial
git commit -m "feat: inicializacion de proyecto agente inteligente buyer con soporte meta graph api y sql server"

# 5. Conectar con su repositorio remoto en GitHub
git remote add origin https://github.com/<TU_USUARIO>/<TU_REPOSITORIO>.git

# 6. Subir los cambios a GitHub
git push -u origin main
```

---

## 📄 Licencia

Este proyecto es propiedad de **Parrilladas El Establo** para uso académico y comercial. Todos los derechos reservados.
