#!/bin/bash

# MARIE Simulator - Script de Configuración para Linux
# Este script ayuda a instalar Java (JRE o JDK) de forma portable o global.

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log()     { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[ADVERTENCIA]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

PROJECT_ROOT=$(cd "$(dirname "$0")/../.." && pwd)

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}   Configuración de Entorno MARIE Simulator       ${NC}"
echo -e "${BLUE}==================================================${NC}"

# 1. Elección entre JRE y JDK
echo -e "\nSeleccione qué desea instalar:"
echo "1) JRE (Solo para ejecutar el simulador)"
echo "2) JDK (Para ejecutar y también compilar/desarrollar)"
echo "3) Salir / Ya tengo Java instalado"
read -p "Opción [1-3]: " TYPE_CHOICE

case $TYPE_CHOICE in
    1)
        JAVA_TYPE="jre"
        JAVA_CMD_CHECK="java"
        log "Has seleccionado instalar un JRE."
        ;;
    2)
        JAVA_TYPE="jdk"
        JAVA_CMD_CHECK="javac"
        log "Has seleccionado instalar un JDK."
        ;;
    *)
        log "Saliendo. No se realizaron cambios."
        exit 0
        ;;
esac

# 2. Verificar si ya existe lo que el usuario eligió
if [ "$JAVA_TYPE" == "jdk" ]; then
    if [ -f "$PROJECT_ROOT/.java_runtime/bin/javac" ] || \
       [ -f "$HOME/.sdkman/candidates/java/current/bin/javac" ] || \
       command -v javac >/dev/null 2>&1; then
        success "Se detectó un JDK ya instalado."
        echo "¿Desea continuar con la instalación de todas formas?"
        echo "1) Sí, continuar"
        echo "2) No, salir"
        read -p "Opción [1-2]: " CONTINUE_CHOICE
        if [ "$CONTINUE_CHOICE" != "1" ]; then
            log "Saliendo. No se realizaron cambios."
            exit 0
        fi
    fi
else
    if [ -f "$PROJECT_ROOT/.java_runtime/bin/java" ] || \
       [ -f "$HOME/.sdkman/candidates/java/current/bin/java" ] || \
       command -v java >/dev/null 2>&1; then
        success "Se detectó un JRE ya instalado."
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

# 3. Elección de método de instalación
echo -e "\n¿Cómo desea instalar Java?"
echo "1) Portable (Descargar dentro de la carpeta del proyecto; no requiere admin)"
echo "2) Global vía Administrador de Paquetes (apt o dnf; requiere sudo)"
echo "3) Global vía SDKMAN (JDK completo, no JRE solo; no requiere admin)"
echo "4) Salir / Ya tengo Java instalado"
read -p "Opción [1-4]: " INSTALL_CHOICE

case $INSTALL_CHOICE in
    1)
        log "Iniciando instalación portable..."
        INSTALL_DIR="$PROJECT_ROOT/.java_runtime"
        mkdir -p "$INSTALL_DIR"

        ARCH=$(uname -m)
        if [ "$ARCH" == "x86_64" ]; then
            BINARY_ARCH="x64"
        elif [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            BINARY_ARCH="aarch64"
        else
            error "Arquitectura $ARCH no soportada automáticamente. Intente instalación global."
            exit 1
        fi

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
            rm -rf "$INSTALL_DIR/tmp" "$INSTALL_DIR/java.tar.gz"
            exit 1
        fi

        EXTRACTED_DIR=$(ls "$INSTALL_DIR/tmp")
        if ! mv "$INSTALL_DIR/tmp/$EXTRACTED_DIR"/* "$INSTALL_DIR/"; then
            error "Error al mover los archivos extraídos."
            rm -rf "$INSTALL_DIR/tmp" "$INSTALL_DIR/java.tar.gz"
            exit 1
        fi

        rm -rf "$INSTALL_DIR/tmp" "$INSTALL_DIR/java.tar.gz"
        success "Java portable instalado correctamente en $INSTALL_DIR"
        ;;
    2)
        if command -v dnf &> /dev/null; then
            log "Detectado Fedora/RHEL (dnf). Requiere privilegios de administrador (sudo)."
            PKG="java-21-openjdk$([ "$JAVA_TYPE" == "jdk" ] && echo "-devel")"
            if ! sudo dnf install -y "$PKG"; then
                error "Error al instalar via dnf."
                exit 1
            fi

            # Verificar si el java activo apunta a la versión no-headless recién instalada
            JAVA_21_BIN="/usr/lib/jvm/java-21-openjdk/bin/java"
            CURRENT_JAVA=$(readlink -f "$(which java)" 2>/dev/null)
            if [ -f "$JAVA_21_BIN" ] && [ "$CURRENT_JAVA" != "$JAVA_21_BIN" ]; then
                warn "Tu sistema tiene otra versión de Java como predeterminada ($CURRENT_JAVA)."
                warn "Si esa versión es headless, MARIE no podrá mostrar su interfaz gráfica."
                echo "¿Deseas cambiar la versión activa de Java a la recién instalada (con soporte gráfico garantizado)?"
                echo "1) Sí, cambiar"
                echo "2) No (si tu versión actual es headless, MARIE no podrá ejecutarse)"
                read -p "Opción [1-2]: " ALT_CHOICE
                if [ "$ALT_CHOICE" == "1" ]; then
                    sudo alternatives --set java "$JAVA_21_BIN"
                    success "Java 21 configurado como versión activa."
                else
                    warn "No se realizaron cambios. Si tu versión activa de Java es headless, MARIE no podrá mostrar su interfaz gráfica."
                fi
            fi

        elif command -v apt-get &> /dev/null; then
            log "Detectado Debian/Ubuntu (apt). Requiere privilegios de administrador (sudo)."
            PKG="openjdk-21-$([ "$JAVA_TYPE" == "jdk" ] && echo "jdk" || echo "jre")"
            if ! sudo apt-get update; then
                error "Error al actualizar repositorios."
                exit 1
            fi
            if ! sudo apt-get install -y "$PKG"; then
                error "Error al instalar via apt."
                exit 1
            fi
        else
            error "No se detectó dnf ni apt. Intente el método portable o SDKMAN."
            exit 1
        fi
        success "Instalación global completada con éxito."
        ;;
    3)
	    SDKMAN_INIT="$HOME/.sdkman/bin/sdkman-init.sh"

    	if [ -s "$SDKMAN_INIT" ]; then
	      log "SDKMAN detectado. Inicializando..."
	      source "$SDKMAN_INIT"
    	else
  	    log "SDKMAN no detectado. Instalando SDKMAN primero..."
	      if ! curl -s "https://get.sdkman.io" | bash; then
	      	error "Error al instalar SDKMAN."
	    	  exit 1
	      fi
  	    export SDKMAN_DIR="$HOME/.sdkman"
  	    source "$SDKMAN_DIR/bin/sdkman-init.sh"
      fi
        log "Instalando Java 21 vía SDKMAN..."
        if ! sdk install java 21.0.10-tem; then
          error "Error al instalar Java mediante SDKMAN."
          exit 1
        fi
        success "Instalación vía SDKMAN completada."
        log "NOTA: Para usar 'java' o 'sdk' manualmente en esta terminal, ejecute: source ~/.bashrc"
        log "O simplemente abra una nueva terminal."
        log "Los scripts del proyecto no dependen de esto (usan rutas directas)."
        ;;
    *)
        log "Saliendo de la configuración."
        exit 0
        ;;
esac

echo -e "\n${GREEN}Configuración finalizada con éxito.${NC}"
echo "Ahora puedes ejecutar el simulador usando los scripts correspondientes."
