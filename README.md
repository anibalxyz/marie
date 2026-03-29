# Simulador MARIE - Modernizado

Fork simplificado del simulador original de la arquitectura **MARIE** (Machine Architecture that is Really Intuitive and Easy). Creado para que cualquier persona pueda ejecutarlo sin fricciones técnicas, automatizando la instalación de Java y la compilación.

## ✨ Mejoras en esta versión

- **Instalación sin complicaciones:** Scripts que instalan Java (JRE/JDK) de forma portable (sin necesidad de permisos de administrador).
- **Compilación simplificada:** Uso de Maven Wrapper para compilar el proyecto con un solo comando.
- **Integración con el Escritorio:** Generadores de accesos directos para Linux y Windows.
- **Interconectividad:** Puedes abrir el Visualizador de Data Path desde el Simulador y viceversa a través del menú "Simulators".
- **Portabilidad total:** El simulador se empaqueta en un único archivo `marie.jar` que incluye todos los recursos (imágenes, archivos de ayuda, etc.).

---

## 🚀 Guía de Inicio Rápido

### Paso 0: Obtener el proyecto

Primero necesitas tener el proyecto en tu computadora. Tienes dos opciones:

**Opción A — Con Git (recomendado):**
Abre una terminal y ejecuta:

```bash
git clone https://github.com/anibalxyz/marie.git
cd marie
```

**Opción B — Sin Git:**
Haz clic en el botón verde **"Code"** en la página del repositorio y selecciona **"Download ZIP"**. Descomprime el archivo y abre la carpeta resultante.

---

### Elige tu camino

#### Camino A: usar el ejecutable precompilado (recomendado)

No necesitas compilar nada. Simplemente descarga el archivo `marie.jar` desde la sección de [Releases](https://github.com/anibalxyz/marie/releases) y colócalo dentro de la carpeta del proyecto.

Sigue los pasos 1, 3 y 4 de esta guía.

> [!TIP]
> Un archivo **JAR** es un paquete que contiene todo el programa listo para funcionar. Para ejecutarlo necesitas tener instalado un **JRE (Java Runtime Environment)**.

#### Camino B: compilar desde el código fuente

Si prefieres compilarlo tu mismo, sigue todos los pasos de esta guía (1, 2, 3 y 4).

---

### 1. Configuración de Java

Si ya tienes **Java 21** instalado puedes saltarte este paso.

Si no lo tienes, ejecuta el script de configuración. Te pedirá elegir entre instalar un **JRE** (suficiente para el Camino A) o un **JDK** (necesario para el Camino B):

- **Linux** — ejecuta en la terminal:

```bash
./scripts/linux/setup.sh
```

- **Windows** — haz clic derecho en `scripts\windows\setup.ps1` y selecciona **"Ejecutar con PowerShell"**. Si aparece un aviso de seguridad, haz clic en **"Abrir"**.
  También puedes ejecutarlo desde una terminal PowerShell (los argumentos `-ExecutionPolicy Bypass` permiten saltarse el aviso de seguridad):
```powershell
  powershell -ExecutionPolicy Bypass -File scripts\windows\setup.ps1
```

---

### 2. Compilar el proyecto (Solo Camino B)

- **Linux** — ejecuta en la terminal:

```bash
./scripts/linux/build.sh
```

- **Windows** — haz clic derecho en `scripts\windows\build.ps1` y selecciona **"Ejecutar con PowerShell"**. Si aparece un aviso de seguridad, haz clic en **"Abrir"**.
  También puedes ejecutarlo desde una terminal PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\windows\build.ps1
```

---

### 3. Ejecutar el Simulador

> [!TIP]
> Este paso ejecuta el simulador directamente desde la terminal. El método recomendado es crear un acceso directo en el escritorio (ver paso 4).

- **Linux** — ejecuta en la terminal:

```bash
./scripts/linux/run.sh
```

- **Windows** — haz clic derecho en `scripts\windows\run.ps1` y selecciona **"Ejecutar con PowerShell"**. Si aparece un aviso de seguridad, haz clic en **"Abrir"**.
  También puedes ejecutarlo desde una terminal PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\windows\run.ps1
```

---

### 4. Crear Acceso Directo en el Escritorio (Recomendado)

Crea un ícono en tu escritorio para abrir el simulador fácilmente. Internamente utiliza los mismos scripts del paso 3.

- **Linux** — ejecuta en la terminal:

```bash
./scripts/linux/create-shortcut.sh
```

- **Windows** — haz clic derecho en `scripts\windows\create-shortcut.ps1` y selecciona **"Ejecutar con PowerShell"**. Si aparece un aviso de seguridad, haz clic en **"Abrir"**.
  También puedes ejecutarlo desde una terminal PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\windows\create-shortcut.ps1
```

---

## 📖 Documentación Original

Este repositorio es un fork de otro repositorio, que a su vez deriva del proyecto original MARIE.

La documentación original (correspondiente al fork intermedio, no al proyecto original) se conserva en [ORIGINAL_README.md](/old-repo/ORIGINAL_README.md). En la carpeta [old-repo](/old-repo/) se incluyen algunos archivos heredados que no forman parte del funcionamiento actual del proyecto. Se mantienen sin modificaciones y únicamente con fines de referencia, ya que no son necesarios para la ejecución ni para el uso principal.

El historial completo de cambios —incluyendo tanto los introducidos en este repositorio como los heredados del fork anterior (excluyendo el proyecto original)— puede consultarse en el log de commits.
