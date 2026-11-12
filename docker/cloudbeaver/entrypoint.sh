#!/bin/bash
set -e

WORKSPACE_DIR="/opt/cloudbeaver/workspace"
CONFIG_DIR="${WORKSPACE_DIR}/GlobalConfiguration/.dbeaver"

# Crear ruta de configuracion inicial si el volumen persistente esta vacio
mkdir -p "${CONFIG_DIR}"

if [ ! -f "${CONFIG_DIR}/data-sources.json" ]; then
    echo "[CloudBeaver Init] Inicializando data-sources.json en volumen persistente..."
    if [ -f "/opt/cloudbeaver-template/data-sources.json" ]; then
        cp /opt/cloudbeaver-template/data-sources.json "${CONFIG_DIR}/data-sources.json"
    fi
fi

# Asegurar permisos correctos en el volumen de trabajo
chown -R dbeaver:dbeaver "${WORKSPACE_DIR}" 2>/dev/null || true

# Ejecutar el comando original de CloudBeaver
exec /opt/cloudbeaver/launch-product.sh "$@"
