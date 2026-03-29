#!/bin/bash

# MARIE Simulator - Script de Configuración para Linux
# Este script ayuda a instalar Java (JRE o JDK) de forma portable o global.

# Colores para la salida
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   Configuración de Entorno MARIE Simulator       ${NC}"
echo -e "${BLUE}==================================================${NC}"

# 0. Verificar si Java 21+ ya está instalado
if command -v java >/dev/null 2>&1; then
    JAVA_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')
    if [ "$JAVA_VERSION" -ge 21 ]; then
        success "Se detectó Java versión $JAVA_VERSION ya instalado en su sistema."
        echo "¿Desea continuar con la instalación de todas formas?"
        echo "1) Sí, continuar"
        echo "2) No, salir"
        read -p "Opción [1-2]: " CONTINUE_CHOICE
        if [ "$CONTINUE_CHOICE" != "1" ]; then
            log "Saliendo. No se realizaron cambios."
            exit 0
        fi
    fi
fi

# 1. Elección entre JRE y JDK
echo -e "\nSeleccione qué desea instalar:"
echo "1) JRE (Solo para ejecutar el simulador)"
echo "2) JDK (Para ejecutar y también compilar/desarrollar)"
read -p "Opción [1-2]: " TYPE_CHOICE

if [ "$TYPE_CHOICE" == "2" ]; then
    JAVA_TYPE="jdk"
    log "Has seleccionado instalar un JDK."
else
    JAVA_TYPE="jre"
    log "Has seleccionado instalar un JRE."
fi

# 2. Elección de método de instalación
echo -e "\n¿Cómo desea instalar Java?"
echo "1) Portable (Descargar dentro de la carpeta del proyecto, no requiere admin)"
echo "2) Global vía Administrador de Paquetes (apt o dnf, requiere sudo)"
echo "3) Global vía SDKMAN (No requiere admin)"
echo "4) Salir / Ya tengo Java instalado"
read -p "Opción [1-4]: " INSTALL_CHOICE

case $INSTALL_CHOICE in
    1)
        # Instalación Portable
        log "Iniciando instalación portable..."
        INSTALL_DIR="$(pwd)/.java_runtime"
        mkdir -p "$INSTALL_DIR"
        
        # Determinar arquitectura
        ARCH=$(uname -m)
        if [ "$ARCH" == "x86_64" ]; then
            BINARY_ARCH="x64"
        elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            BINARY_ARCH="aarch64"
        else
            error "Arquitectura $ARCH no soportada automáticamente. Intente instalación global."
            exit 1
        fi

        # URL de Eclipse Temurin 21
        URL="https://api.adoptium.net/v3/binary/latest/21/ga/linux/$BINARY_ARCH/$JAVA_TYPE/hotspot/normal/eclipse?project=jdk"
        
        log "Descargando Java 21 desde Adoptium..."
        if ! curl -L "$URL" -o "$INSTALL_DIR/java.tar.gz"; then
            error "Error al descargar Java. Verifique su conexión a internet."
            exit 1
        fi
        
        log "Extrayendo archivos..."
        mkdir -p "$INSTALL_DIR/tmp"
        if ! tar -xzf "$INSTALL_DIR/java.tar.gz" -C "$INSTALL_DIR/tmp"; then
            error "Error al extraer los archivos de Java."
            exit 1
        fi
        
        EXTRACTED_DIR=$(ls "$INSTALL_DIR/tmp")
        if ! mv "$INSTALL_DIR/tmp/$EXTRACTED_DIR"/* "$INSTALL_DIR/"; then
            error "Error al mover los archivos extraídos."
            exit 1
        fi
        
        rm -rf "$INSTALL_DIR/tmp" "$INSTALL_DIR/java.tar.gz"
        success "Java portable instalado correctamente en $INSTALL_DIR"
        ;;
    2)
        # Instalación vía apt o dnf
        if command -v dnf &> /dev/null; then
            log "Detectado Fedora/RHEL (dnf). Requiere privilegios de administrador (sudo)."
            if [ "$JAVA_TYPE" == "jdk" ]; then
                if ! sudo dnf install -y java-21-openjdk-devel; then error "Error al instalar via dnf."; exit 1; fi
            else
                if ! sudo dnf install -y java-21-openjdk; then error "Error al instalar via dnf."; exit 1; fi
            fi
        elif command -v apt-get &> /dev/null; then
            log "Detectado Debian/Ubuntu (apt). Requiere privilegios de administrador (sudo)."
            if ! sudo apt-get update; then error "Error al actualizar repositorios (apt update)."; exit 1; fi
            if [ "$JAVA_TYPE" == "jdk" ]; then
                if ! sudo apt-get install -y openjdk-21-jdk; then error "Error al instalar via apt."; exit 1; fi
            else
                if ! sudo apt-get install -y openjdk-21-jre; then error "Error al instalar via apt."; exit 1; fi
            fi
        else
            error "No se detectó dnf ni apt. Intente el método portable o SDKMAN."
            exit 1
        fi
        success "Instalación global completada con éxito."
        ;;
    3)
        # SDKMAN
        if ! command -v sdk &> /dev/null; then
            log "SDKMAN no detectado. Instalando SDKMAN primero..."
            if ! curl -s "https://get.sdkman.io" | bash; then
                error "Error al instalar SDKMAN."
                exit 1
            fi
            export SDKMAN_DIR="$HOME/.sdkman"
            [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
        fi
        log "Instalando Java 21 vía SDKMAN..."
        if ! sdk install java 21-tem; then
            error "Error al instalar Java mediante SDKMAN."
            exit 1
        fi
        success "Instalación vía SDKMAN completada."
        warn "NOTA: Para usar 'java' o 'sdk' en esta terminal, ejecute: source ~/.bashrc"
        warn "O simplemente abra una nueva terminal."
        ;;
    *)
        log "Saliendo de la configuración."
        exit 0
        ;;
esac

echo -e "\n${GREEN}Configuración finalizada con éxito.${NC}"
echo "Ahora puedes ejecutar el simulador usando los scripts correspondientes."
