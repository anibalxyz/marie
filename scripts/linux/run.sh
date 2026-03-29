#!/bin/bash

# MARIE Simulator - Script de Ejecución para Linux
# Este script lanza el simulador utilizando el JAR generado.

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Determinar el comando de Java a usar
PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SDKMAN_JAVA="$HOME/.sdkman/candidates/java/current/bin/java"

if [ -f "$PROJECT_ROOT/.java_runtime/bin/java" ]; then
    JAVA_CMD="$PROJECT_ROOT/.java_runtime/bin/java"
    log "Usando Java portable (.java_runtime)."
elif [ -f "$SDKMAN_JAVA" ]; then
    JAVA_CMD="$SDKMAN_JAVA"
    log "Usando Java instalado vía SDKMAN."
elif command -v java >/dev/null 2>&1; then
    JAVA_CMD="java"
    log "Usando Java del sistema."
else
    error "No se encontró Java. Por favor ejecute ./scripts/linux/setup.sh primero."
    exit 1
fi

# 2. Verificar que exista el JAR
JAR_FILE="$PROJECT_ROOT/target/marie.jar"
if [ ! -f "$JAR_FILE" ]; then
    error "No se encontró el archivo $JAR_FILE. Por favor ejecute ./scripts/linux/build.sh primero."
    exit 1
fi

# 3. Lanzar el simulador
log "Iniciando MARIE Simulator..."
$JAVA_CMD -jar "$JAR_FILE"
