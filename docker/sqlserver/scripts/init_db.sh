#!/bin/bash
echo "[SQL Server Init] Esperando a que el motor SQL Server este listo..."

SQLCMD=""
if [ -f "/opt/mssql-tools18/bin/sqlcmd" ]; then
    SQLCMD="/opt/mssql-tools18/bin/sqlcmd"
elif [ -f "/opt/mssql-tools/bin/sqlcmd" ]; then
    SQLCMD="/opt/mssql-tools/bin/sqlcmd"
else
    SQLCMD="sqlcmd"
fi

SA_PASS="${MSSQL_SA_PASSWORD}"
APP_PASS="${DB_PASSWORD:-$MSSQL_SA_PASSWORD}"

if [ -z "$SA_PASS" ]; then
    echo "[SQL Server Init] ERROR: Variable de entorno MSSQL_SA_PASSWORD no configurada."
    exit 1
fi

# Intentar conexion hasta 60 veces (120 segundos max)
for i in $(seq 1 60); do
    if $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -Q "SELECT 1" > /dev/null 2>&1; then
        echo "[SQL Server Init] Motor SQL Server responde correctamente."
        break
    fi
    echo "[SQL Server Init] Esperando conexion... ($i/60)"
    sleep 2
done

echo "[SQL Server Init] Verificando base de datos buyer..."
HAS_BUYER=$($SQLCMD -S localhost -U sa -P "$SA_PASS" -C -h -1 -W -Q "SET NOCOUNT ON; SELECT COUNT(*) FROM sys.databases WHERE name = 'buyer'" 2>/dev/null | tr -d '\r\n ')

if [ "$HAS_BUYER" != "1" ]; then
    if [ -f "/docker-init/buyer.bak" ]; then
        echo "[SQL Server Init] Archivo buyer.bak detectado en /docker-init/. Restaurando backup nativo..."
        $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -Q "RESTORE DATABASE buyer FROM DISK = '/docker-init/buyer.bak' WITH MOVE 'buyer' TO '/var/opt/mssql/data/buyer.mdf', MOVE 'buyer_log' TO '/var/opt/mssql/data/buyer_log.ldf', REPLACE;"
        echo "[SQL Server Init] Sincronizando login buyer_app..."
        $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -Q "IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'buyer_app') CREATE LOGIN [buyer_app] WITH PASSWORD = '${APP_PASS}', CHECK_POLICY = OFF; ALTER LOGIN [buyer_app] WITH PASSWORD = '${APP_PASS}'; USE buyer; IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'buyer_app') CREATE USER [buyer_app] FOR LOGIN [buyer_app]; ALTER ROLE [db_owner] ADD MEMBER [buyer_app];"
        echo "[SQL Server Init] Base de datos buyer restaurada exitosamente desde backup binario."
    elif [ -f "/docker-init/01_init_schema_and_data.sql" ]; then
        echo "[SQL Server Init] Base de datos buyer no encontrada. Ejecutando script de inicializacion 01_init_schema_and_data.sql..."
        $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -v DB_PASSWORD="$APP_PASS" -i /docker-init/01_init_schema_and_data.sql
        echo "[SQL Server Init] Base de datos buyer inicializada con exito desde script SQL."
    else
        echo "[SQL Server Init] AVISO: No se encontro archivo de inicializacion ni backup para buyer."
    fi
else
    echo "[SQL Server Init] La base de datos buyer ya existe."
fi

# Aplicar migraciones aditivas e idempotentes si existen
if [ -f "/docker-init/02_migracion_carta_flexible.sql" ]; then
    echo "[SQL Server Init] Aplicando migracion de carta flexible 02_migracion_carta_flexible.sql..."
    $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -d buyer -i /docker-init/02_migracion_carta_flexible.sql
fi

if [ -f "/docker-init/03_cargar_catalogo_real.sql" ]; then
    echo "[SQL Server Init] Aplicando carga de catalogo real 03_cargar_catalogo_real.sql..."
    $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -d buyer -i /docker-init/03_cargar_catalogo_real.sql
fi

if [ -f "/docker-init/04_migracion_gasto_anuncio.sql" ]; then
    echo "[SQL Server Init] Aplicando migracion de gasto anuncio 04_migracion_gasto_anuncio.sql..."
    $SQLCMD -S localhost -U sa -P "$SA_PASS" -C -d buyer -i /docker-init/04_migracion_gasto_anuncio.sql
fi

echo "[SQL Server Init] Inicializacion y sincronizacion completada exitosamente."
