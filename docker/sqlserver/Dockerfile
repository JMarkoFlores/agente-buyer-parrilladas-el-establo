FROM mcr.microsoft.com/mssql/server:2022-latest

USER root

# Crear directorios para scripts e init
RUN mkdir -p /docker-init /docker-scripts

# Copiar scripts y archivos de inicializacion
COPY scripts/entrypoint.sh /docker-scripts/entrypoint.sh
COPY scripts/init_db.sh /docker-scripts/init_db.sh
COPY init/ /docker-init/

# Dar permisos de ejecucion
RUN chmod +x /docker-scripts/entrypoint.sh /docker-scripts/init_db.sh &&     chown -R mssql:root /docker-scripts /docker-init

USER mssql

ENTRYPOINT ["/docker-scripts/entrypoint.sh"]
