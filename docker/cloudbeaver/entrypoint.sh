#!/bin/bash
set -e

WORKSPACE_DIR="/opt/cloudbeaver/workspace"
CONFIG_DIR="${WORKSPACE_DIR}/GlobalConfiguration/.dbeaver"

# Crear ruta de configuracion inicial si el volumen persistente esta vacio
mkdir -p "${CONFIG_DIR}"

# Sembrar siempre la configuracion global (conexiones compartidas preconfiguradas).
# ponytail: sobrescribe en cada arranque; las conexiones creadas en la UI viven en user-projects.
if [ -f "/opt/cloudbeaver-template/data-sources.json" ]; then
    echo "[CloudBeaver Init] Sembrando data-sources.json global con la conexion buyer..."
    cp /opt/cloudbeaver-template/data-sources.json "${CONFIG_DIR}/data-sources.json"
fi

# Asegurar permisos correctos en el volumen de trabajo
chown -R dbeaver:dbeaver "${WORKSPACE_DIR}" 2>/dev/null || true

# Ejecutar el comando original de CloudBeaver
exec /opt/cloudbeaver/launch-product.sh "$@"
