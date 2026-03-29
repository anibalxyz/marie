#!/bin/bash

# MARIE Simulator - Generador de Acceso Directo para Linux
# Este script crea un archivo .desktop para lanzar el simulador desde el menú de aplicaciones.

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Rutas
PROJECT_DIR=$(pwd)
ICON_PATH="$PROJECT_DIR/src/main/resources/M.png"
EXEC_PATH="$PROJECT_DIR/run.sh"
DESKTOP_FILE="$HOME/.local/share/applications/marie-simulator.desktop"

# 2. Verificar que run.sh existe
if [ ! -f "$EXEC_PATH" ]; then
    error "No se encontró run.sh. Por favor, asegúrese de estar en la raíz del proyecto."
    exit 1
fi

# 3. Crear el archivo .desktop
log "Generando archivo .desktop en $DESKTOP_FILE..."

cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Version=1.0
Type=Application
Name=MARIE Simulator
Comment=Simulador de arquitectura MARIE
Exec=/bin/bash "$EXEC_PATH"
Icon=$ICON_PATH
Path=$PROJECT_DIR
Terminal=false
Categories=Education;Science;
Keywords=MARIE;Simulator;Computer;Architecture;
EOF

# 4. Dar permisos de ejecución
chmod +x "$DESKTOP_FILE"

success "Acceso directo creado correctamente."
echo "Ahora puedes encontrar 'MARIE Simulator' en tu menú de aplicaciones."
