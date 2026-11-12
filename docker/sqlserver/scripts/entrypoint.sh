#!/bin/bash
set -e

# Iniciar script de inicializacion en segundo plano
/docker-scripts/init_db.sh &

# Ejecutar el servidor SQL en primer plano
exec /opt/mssql/bin/sqlservr
