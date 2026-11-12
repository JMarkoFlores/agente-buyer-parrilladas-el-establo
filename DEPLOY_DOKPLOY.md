# 🚀 GUÍA DE DESPLIEGUE EN DOKPLOY — AGENTE BUYER (PARRILLADAS EL ESTABLO)

Esta guía documenta la preparación, configuración, procedimiento de respaldo/restauración, rotación de secretos y transición segura del sistema **Agente Inteligente Multicanal BUYER** de **Parrilladas El Establo** hacia una instancia remota administrada con **Dokploy**.

---

## 1. RESUMEN DE LA ARQUITECTURA EN DOKPLOY

El sistema se compone de cinco servicios desacoplados definidos en [`compose.dokploy.yml`](file:///C:/Users/jeanm/Downloads/agente-buyer/compose.dokploy.yml):

```
                                  [ INTERNET ]
                                        │
                                        ▼ (HTTPS / 443)
                             [ Dokploy Traefik Proxy ]
                             (Red: dokploy-network)
                                 │              │
                   ┌─────────────┴──┐        ┌──┴───────────────┐
                   ▼ (Puerto 80)    │        ▼ (Puerto 8978)    │
            ┌──────────────┐        │ ┌──────────────────────┐  │
            │   frontend   │        │ │     cloudbeaver      │  │
            │(React+Nginx) │        │ │(Admin SQL con Auth)  │  │
            └──────┬───────┘        │ └──────────┬───────────┘  │
                   │                │            │              │
═══════════════════╪════════════════╪════════════╪══════════════╪═════════════
 RED PRIVADA: internal              │            │
                   ▼ (/api/)        │            │
            ┌──────────────┐        │            │
            │   backend    │        │            │
            │(Flask+Gunic.)│        │            │
            └──────┬───────┘        │            │
                   │                │            │
                   ├────────────────┼────────────┤
                   ▼                │            │
            ┌──────────────┐        │            │
            │  sqlserver   │◄───────┘            │
            │ (MSSQL 2022) │◄────────────────────┘
            └──────▲───────┘
                   │ (AppLock)
            ┌──────┴───────┐
            │  scheduler   │ ──(Salida HTTPS)──► [ Meta Graph API v27.0 ]
            │(APScheduler) │
            └──────────────┘
```

### Principios de Aislamiento y Red en Dokploy
1. **Red Externa `dokploy-network`**: Dokploy y su proxy inverso (Traefik) encaminan el tráfico HTTPS externo únicamente a los servicios `frontend` (puerto interno 80) y `cloudbeaver` (puerto interno 8978).
2. **Red Interna `internal`**: Conecta privadamente `backend`, `sqlserver`, `scheduler`, `frontend` y `cloudbeaver`. No expone ningún puerto al host público (0.0.0.0).
3. **Frontend como Gateway de API**: El navegador del usuario accede a `https://buyer.tu-dominio.com/`. Nginx sirve el bundle de React y reenvía internamente las peticiones `/api/*` hacia `http://backend:5000/api/`. El backend Flask **no** está expuesto al internet.
4. **SQL Server sin exposición pública**: El puerto 1433 **no** se publica en el host. Solo es accesible por los contenedores internos.
5. **Scheduler sin puerto**: Proceso trabajador independiente (*worker*). Realiza consultas a SQL Server mediante bloqueo distribuido (`sp_getapplock`) y envía tráfico HTTP saliente hacia Meta Graph API.
6. **Volúmenes Persistentes Nombrados**: Se reemplazaron los bind mounts de Windows por volúmenes gestionados por Docker (`sqlserver_data` y `cloudbeaver_data`), evitando problemas de permisos en Linux y colisiones globales.

---

## 2. COMPARATIVA: ENTORNO LOCAL vs DOKPLOY

| Característica | Local (`compose.yaml`) | Dokploy (`compose.dokploy.yml`) | Motivo del Cambio |
| :--- | :--- | :--- | :--- |
| **Nombres de Contenedor** | Fijos (`establo_backend`, etc.) | **Dinámicos** (gestionados por Compose) | Evita colisiones entre despliegues o stacks en el servidor Dokploy. |
| **Publicación de Puertos** | Expuestos en 0.0.0.0 (`1433`, `5000`, `3000`, `8978`) | **Solo `expose` interno** (`80`, `8978`, `5000`) | Previene conflictos de puerto en el host y cierra vectores de ataque directos. |
| **Enrutamiento Web** | Host directo `localhost:3000` | **Traefik + SSL Let's Encrypt** en `dokploy-network` | Dokploy administra certificados automáticos y enrutamiento por nombre de dominio. |
| **Nombres de Volúmenes** | Globales (`establo_sqlserver_data`) | **Ámbito de Proyecto** (`sqlserver_data`) | Previene sobreescritura accidental entre proyectos Dokploy en el mismo VPS. |
| **Configuración CloudBeaver** | Bind mount de Windows `./docker/cloudbeaver/...` | **Dockerfile con inicialización automática en volumen** | Portabilidad 100% en Linux; sin errores de permisos `dbeaver:dbeaver`. |
| **Contraseñas por Defecto** | Hardcodeadas en fallbacks (`EstabloBuyer2026!DbPass`) | **Estrictamente por Variables de Entorno** | Seguridad de producción y cumplimiento de auditoría. |
| **Healthcheck SQL Server** | Contraseña de respaldo en texto plano | Interpolación segura de variable `$$MSSQL_SA_PASSWORD` | Previene filtración de credenciales en inspecciones de Docker inspect. |
| **Estado Inicial Scheduler** | Activo (`META_SYNC_ENABLED=true`) | **Desactivado por defecto (`META_SYNC_ENABLED=false`)** | Previene que dos servidores sincronicen y respondan a la vez a las mismas cuentas Meta. |
| **Modo Auto-Reply Inicial** | Envío real (`AUTO_REPLY_DRY_RUN=false`) | **Simulación segura (`AUTO_REPLY_DRY_RUN=true`)** | Impide despachos duplicados antes de confirmar la restauración de datos. |

---

## 3. IDENTIFICACIÓN Y ROTACIÓN DE CREDENCIALES COMPROMETIDAS

> [!WARNING]
> Debido a la exposición previa de credenciales en diagnósticos, los siguientes seis secretos deben considerarse comprometidos y ser rotados antes o durante el cambio a producción en Dokploy.

### Listado de Credenciales a Rotar (Valores Omitidos)
1. `META_APP_SECRET`: Secreto de la aplicación Meta for Developers.
2. `META_PAGE_ACCESS_TOKEN`: Token de acceso de larga duración para la Fan Page de Facebook.
3. `META_IG_ACCESS_TOKEN`: Token de acceso para la cuenta profesional de Instagram Graph API.
4. `MSSQL_SA_PASSWORD` y `DB_PASSWORD`: Contraseñas de administración (`sa`) y usuario aplicativo (`buyer_app`) en SQL Server.
5. `ADMIN_API_KEY`: Clave de cabecera (`X-Admin-Token` / `X-API-Key`) que protege los endpoints administrativos del backend.
6. `SECRET_KEY`: Clave criptográfica para firmas de sesión de Flask.

### Procedimiento de Rotación Paso a Paso

#### A. Rotar Secretos de Meta (Facebook e Instagram)
1. Ingrese a [Meta for Developers](https://developers.facebook.com/apps/).
2. Seleccione la App del sistema Agente BUYER.
3. Diríjase a **Configuración** $\rightarrow$ **Básica**.
4. En **Secreto de la app**, haga clic en **Restablecer**. Copie el nuevo `META_APP_SECRET`.
5. Ingrese a la herramienta [Graph API Explorer](https://developers.facebook.com/tools/explorer/).
6. Genere un nuevo **User Token** con permisos: `pages_show_list`, `pages_read_engagement`, `pages_manage_engagement`, `pages_read_user_content`, `instagram_basic`, `instagram_manage_comments`.
7. Convierta el token a token de página permanente intercambiándolo en el endpoint `oauth/access_token` (`grant_type=fb_exchange_token`).
8. Verifique el token en el [Depurador de Tokens de Acceso](https://developers.facebook.com/tools/debug/accesstoken/).

#### B. Generar Claves Criptográficas Seguras para Dokploy
Ejecute en un terminal seguro (Linux o PowerShell) para generar cadenas aleatorias de alta entropía:

```bash
# Para SECRET_KEY de Flask (64 caracteres hexadecimales)
python -c "import secrets; print(secrets.token_hex(32))"

# Para ADMIN_API_KEY del Backend
python -c "import secrets; print(secrets.token_urlsafe(32))"

# Para contraseñas de SQL Server (cumplen política de complejidad: mayúsculas, minúsculas, números y símbolos)
python -c "import secrets, string; alphabet = string.ascii_letters + string.digits + '!@#%*'; print(''.join(secrets.choice(alphabet) for _ in range(24)))"
```

---

## 4. PROCEDIMIENTO DE RESPALDO Y RESTAURACIÓN DE LA BASE DE DATOS

Para garantizar que **no se pierdan comentarios reales, registros de BUYERS, respuestas automáticas con estado `ENVIADA`, identificadores externos de Meta ni auditorías**, existen dos mecanismos:

### Método 1: Inicialización Automática desde el Repositorio (Recomendado para Dokploy)
El archivo [`docker/sqlserver/init/01_init_schema_and_data.sql`](file:///C:/Users/jeanm/Downloads/agente-buyer/docker/sqlserver/init/01_init_schema_and_data.sql) ha sido actualizado e incluye:
- El esquema completo de las 23 tablas.
- **27 interacciones reales** de Facebook e Instagram (incluyendo los comentarios 205, 206, 207, 252 y 253).
- **23 respuestas automáticas** (incluyendo las 19 con estado `ENVIADA` y sus correspondientes `id_respuesta_meta`).
- **29 eventos de integración**.
- Creación de logins parametrizada dinámicamente mediante `$(DB_PASSWORD)` (sin contraseñas hardcodeadas).

Al iniciar el contenedor de SQL Server en Dokploy con un volumen vacío, el script [`init_db.sh`](file:///C:/Users/jeanm/Downloads/agente-buyer/docker/sqlserver/scripts/init_db.sh) ejecuta automáticamente este archivo aplicando la contraseña segura inyectada por Dokploy.

### Método 2: Respaldo Nativo Binario (.bak) y Restauración
Si se desea realizar una clonación binaria bit a bit exacta desde el contenedor local:

#### Paso 1: Generar Respaldo en Docker Desktop Local
```powershell
# Ejecutar respaldo nativo sin detener ni bloquear la base activa
docker exec establo_sqlserver mkdir -p /var/opt/mssql/backup
docker exec establo_sqlserver /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "EstabloBuyer2026!DbPass" -C -Q "BACKUP DATABASE buyer TO DISK = '/var/opt/mssql/backup/buyer_live.bak' WITH FORMAT, INIT;"

# Copiar el archivo .bak a la máquina anfitriona
docker cp establo_sqlserver:/var/opt/mssql/backup/buyer_live.bak ./buyer_live.bak
```

#### Paso 2: Transferir el Archivo al Servidor de Dokploy
```bash
scp ./buyer_live.bak usuario@servidor-dokploy:/tmp/buyer_live.bak
```

#### Paso 3: Restaurar en el Contenedor SQL Server de Dokploy
```bash
# Obtener el ID del contenedor de SQL Server en Dokploy
SQL_CONTAINER=$(docker ps -q -f name=sqlserver)

# Copiar el archivo al contenedor
docker cp /tmp/buyer_live.bak $SQL_CONTAINER:/docker-init/buyer.bak

# Restaurar la base de datos
docker exec $SQL_CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "RESTORE DATABASE buyer FROM DISK = '/docker-init/buyer.bak' WITH MOVE 'buyer' TO '/var/opt/mssql/data/buyer.mdf', MOVE 'buyer_log' TO '/var/opt/mssql/data/buyer_log.ldf', REPLACE;"

# Sincronizar el login y usuario de la aplicación con la nueva contraseña
docker exec $SQL_CONTAINER /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'buyer_app') CREATE LOGIN [buyer_app] WITH PASSWORD = '$DB_PASSWORD', CHECK_POLICY = OFF; ALTER LOGIN [buyer_app] WITH PASSWORD = '$DB_PASSWORD'; USE buyer; IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'buyer_app') CREATE USER [buyer_app] FOR LOGIN [buyer_app]; ALTER ROLE [db_owner] ADD MEMBER [buyer_app];"
```

---

## 5. PROCEDIMIENTO SEGURO DE CAMBIO DE ENTORNO (CUTOVER)

> [!IMPORTANT]
> **REGLA FUNDAMENTAL DE SEGURIDAD**: Nunca deben existir dos instancias del `scheduler` activas concurrentemente contra las mismas cuentas de Meta, ya que esto provocaría respuestas duplicadas a clientes y bloqueos por límites de tasa (*rate limit*).

### Protocolo de 4 Fases para el Cambio

```
[FASE 1: Despliegue Remoto Pasivo]
  - Dokploy arranca con:
    * META_SYNC_ENABLED=false
    * AUTO_REPLY_DRY_RUN=true
  - Local sigue activo atendiendo redes.

[FASE 2: Verificación de Integridad en Dokploy]
  - Comprobar /api/health (200 OK)
  - Comprobar /api/db/status (23 tablas presentes)
  - Comprobar /api/facebook/status (conectado)
  - Comprobar interfaz React y CloudBeaver.

[FASE 3: Apagado Controlado del Scheduler Local]
  - Detener scheduler local:
    docker compose stop scheduler
  - Local queda en modo solo lectura / interfaz.

[FASE 4: Activación del Scheduler en Dokploy]
  - Cambiar en Dokploy:
    * META_SYNC_ENABLED=true
    * AUTO_REPLY_DRY_RUN=false
  - Redesplegar stack Dokploy.
  - El scheduler remoto asume el liderazgo exclusivo con AppLock.
```

---

## 6. INSTRUCCIONES PASO A PASO EN LA INTERFAZ DE DOKPLOY

### Paso 1: Subir el Repositorio a GitHub Privado
Asegúrese de que el repositorio contenga los archivos preparados:
```bash
git add .gitignore .dockerignore .env.docker.example .env.dokploy.example compose.dokploy.yml docker/ frontend/ backend/ DEPLOY_DOKPLOY.md
git commit -m "feat: configuracion de produccion Dokploy con seguridad y persistencia verificada"
git push origin main
```
*(Verifique con `git status` que los archivos `.env` y los `.bak` permanezcan sin seguimiento).*

### Paso 2: Crear el Proyecto en Dokploy
1. Acceda al panel web de Dokploy (`https://dokploy.tu-servidor.com`).
2. En el menú lateral, haga clic en **Projects** $\rightarrow$ **Create Project**.
3. Ingrese el nombre: `agente-buyer`.

### Paso 3: Crear el Servicio Docker Compose
1. Dentro del proyecto `agente-buyer`, haga clic en **Create Service**.
2. Seleccione **Compose** (NO Docker Stack, ya que Docker Compose es el que admite la compilación local con directivas `build`).
3. Asigne el nombre al servicio Compose: `buyer-stack`.

### Paso 4: Conectar el Repositorio Git
1. En la pestaña **General** del servicio Compose:
   - **Source Type**: GitHub (o Git Provider configurado).
   - **Repository**: Seleccione el repositorio privado `agente-buyer`.
   - **Branch**: `main`.
   - **Compose Path**: `compose.dokploy.yml` (especificar este archivo explícitamente).

### Paso 5: Configurar las Variables de Entorno en Dokploy
1. Haga clic en la pestaña **Environment**.
2. Abra el archivo [`.env.dokploy.example`](file:///C:/Users/jeanm/Downloads/agente-buyer/.env.dokploy.example) como referencia.
3. Copie y pegue las variables completando sus valores reales rotados:
   - `MSSQL_SA_PASSWORD` y `DB_PASSWORD`: Sus contraseñas seguras generadas.
   - `SECRET_KEY` y `ADMIN_API_KEY`: Sus claves criptográficas generadas.
   - `META_*`: Credenciales de Meta rotadas.
   - **Importante para el primer despliegue**:
     ```ini
     META_SYNC_ENABLED=false
     AUTO_REPLY_DRY_RUN=true
     ```
4. Haga clic en **Save**.

### Paso 6: Configurar Dominio y Certificados SSL para el Frontend
1. En la pestaña **Domains** del servicio Compose:
2. Haga clic en **Add Domain**:
   - **Host**: `buyer.elestablo.pe` (o el subdominio que apunte al VPS).
   - **Service Name**: `frontend` (el nombre del servicio en el Compose).
   - **Container Port**: `80`.
   - **HTTPS**: Active la casilla (Let's Encrypt generará el certificado automáticamente).
   - **Redirect to HTTPS**: Activado.
3. Guarde la configuración.

### Paso 7: Configurar Acceso a CloudBeaver (Opcional / Seguro)
Si requiere acceso web para administrar SQL Server:
1. En la pestaña **Domains**, haga clic en **Add Domain**:
   - **Host**: `db-buyer.elestablo.pe`.
   - **Service Name**: `cloudbeaver`.
   - **Container Port**: `8978`.
   - **HTTPS**: Activado.
2. Nota de seguridad: CloudBeaver tiene deshabilitado el acceso anónimo (`CLOUDBEAVER_APP_ANONYMOUS_ACCESS_ENABLED=false`). Al ingresar por primera vez, el asistente solicita crear el usuario administrador inicial.

### Paso 8: Desplegar el Stack en Dokploy
1. Haga clic en el botón **Deploy** en la esquina superior derecha.
2. Dokploy clonará el repositorio, compilará las imágenes de los cinco servicios en el servidor Linux, creará los volúmenes persistentes y levantará los contenedores en orden con sus healthchecks.

### Paso 9: Validar los Cinco Servicios en Dokploy
Una vez completado el despliegue:
1. Ingrese a la URL pública del frontend (`https://buyer.tu-dominio.com/`). Verifique que la interfaz cargue correctamente.
2. Revise que la pestaña de Diagnóstico (`/api/db/status`) reporte `status: connected` y `dbo_tables_count: 23`.
3. Revise que los estados de Meta (`/api/facebook/status` e `/api/instagram/status`) reporten `conectado: true`.
4. En el visor de Respuestas Automáticas, compruebe que se muestren las 23 respuestas históricas (19 `ENVIADA`, 2 `SIMULADA`, 2 `OMITIDA`).

### Paso 10: Ejecutar el Cutover Final
1. En su máquina local (Docker Desktop), detenga el scheduler:
   ```powershell
   docker compose stop scheduler
   ```
2. En Dokploy, diríjase a la pestaña **Environment**:
   - Cambie `META_SYNC_ENABLED=true`
   - Cambie `AUTO_REPLY_DRY_RUN=false`
3. Haga clic en **Save** y luego en **Redeploy**.
4. En la pestaña **Logs** de Dokploy para el contenedor `scheduler`, verifique:
   ```text
   [Scheduler] Instancia ÚNICA de APScheduler confirmada como LÍDER activo
   [Scheduler] Trabajo programado registrado: 'job_meta_sync_periodico' (cada 60s)
   ```
5. Realice una prueba final con un comentario nuevo autorizado en una publicación de Facebook o Instagram y confirme la respuesta automática en tiempo real.

---

## 7. PROBLEMAS PENDIENTES Y RECOMENDACIONES DE OPERACIÓN

1. **Permiso `read_insights` en Meta**: El diagnóstico reportó que el permiso `read_insights` está pendiente en la App de Meta. Por tal motivo, las métricas de publicaciones obtienen `total_reacciones` pero mantienen `alcance` e `impresiones` en `NULL` (comportamiento esperado y seguro implementado en el backend).
2. **Protección Adicional para CloudBeaver**: Si bien CloudBeaver requiere autenticación nativa, se recomienda limitar el acceso a su dominio mediante Basic Auth de Traefik o restringirlo por lista blanca de IPs si se va a mantener público en internet.
3. **Monitoreo de Expiración de Tokens de Meta**: Los tokens de Meta pueden invalidarse tras cambios de contraseña en Facebook o políticas de caducidad cada 60 días. Se recomienda verificar periódicamente el endpoint `/api/facebook/status`.
