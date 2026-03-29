#!/bin/bash

# MARIE Simulator - Script de Compilación para Linux
# Este script utiliza el Maven Wrapper para compilar el proyecto.

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 1. Detección de Java (JDK con prioridad)
PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)
PORTABLE_JDK="$PROJECT_ROOT/.java_runtime/bin/javac"
SDKMAN_JDK="$HOME/.sdkman/candidates/java/current/bin/javac"

if [ -f "$PORTABLE_JDK" ]; then
    log "Se utilizará el JDK portable (.java_runtime)."
    export JAVA_HOME="$PROJECT_ROOT/.java_runtime"
elif [ -f "$SDKMAN_JDK" ]; then
    log "Se utilizará el JDK instalado vía SDKMAN."
    export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
elif command -v javac >/dev/null 2>&1; then
    log "Se utilizará el JDK instalado globalmente en el sistema."
    # En este caso no forzamos JAVA_HOME, dejamos que mvnw lo detecte
else
    error "No se encontró un JDK (javac). Se requiere para compilar."
    error "Por favor ejecute ./scripts/linux/setup.sh y elija instalar el JDK."
    exit 1
fi

# 2. Compilar
log "Iniciando compilación con Maven Wrapper..."
if "$PROJECT_ROOT/mvnw" -f "$PROJECT_ROOT/pom.xml" clean package; then
    success "Compilación exitosa. El archivo se encuentra en target/marie.jar"
else
    error "La compilación falló."
    exit 1
fi
