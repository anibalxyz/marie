# MARIE Simulator - Script de Configuración para Windows
# Este script ayuda a instalar Java (JRE o JDK) de forma portable o global.

function Write-Log($msg)          { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Success($msg)      { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Warn($msg)         { Write-Host "[ADVERTENCIA] $msg" -ForegroundColor Yellow }
function Write-Error-Custom($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

$projectRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName

Write-Host "==================================================" -ForegroundColor Blue
Write-Host "   Configuración de Entorno MARIE Simulator       " -ForegroundColor Blue
Write-Host "==================================================" -ForegroundColor Blue

# 1. Elección entre JRE y JDK
Write-Host "`nSeleccione qué desea instalar:"
Write-Host "1) JRE (Solo para ejecutar el simulador)"
Write-Host "2) JDK (Para ejecutar y también compilar/desarrollar)"
Write-Host "3) Salir / Ya tengo Java instalado"
$typeChoice = Read-Host "Opción [1-3]"

switch ($typeChoice) {
    "2" {
        $javaType = "jdk"
        Write-Log "Has seleccionado instalar un JDK."
    }
    "3" {
        Write-Log "Saliendo. No se realizaron cambios."
        Read-Host "`nPresiona Enter para cerrar"
        exit 0
    }
    default {
        $javaType = "jre"
        Write-Log "Has seleccionado instalar un JRE."
    }
}

# 2. Verificar si ya existe lo que el usuario eligió
$portableJava  = Join-Path $projectRoot ".java_runtime\bin\java.exe"
$portableJavac = Join-Path $projectRoot ".java_runtime\bin\javac.exe"

if ($javaType -eq "jdk") {
    $alreadyInstalled = (Test-Path $portableJavac) -or
                        (Get-Command javac -ErrorAction SilentlyContinue)
    if ($alreadyInstalled) {
        Write-Success "Se detectó un JDK ya instalado."
        Write-Host "¿Desea continuar con la instalación de todas formas?"
        Write-Host "1) Sí, continuar"
        Write-Host "2) No, salir"
        $continueChoice = Read-Host "Opción [1-2]"
        if ($continueChoice -ne "1") {
            Write-Log "Saliendo. No se realizaron cambios."
            Read-Host "`nPresiona Enter para cerrar"
            exit 0
        }
    }
} else {
    $alreadyInstalled = (Test-Path $portableJava) -or
                        (Get-Command java -ErrorAction SilentlyContinue)
    if ($alreadyInstalled) {
        Write-Success "Se detectó un JRE ya instalado."
        Write-Host "¿Desea continuar con la instalación de todas formas?"
        Write-Host "1) Sí, continuar"
        Write-Host "2) No, salir"
        $continueChoice = Read-Host "Opción [1-2]"
        if ($continueChoice -ne "1") {
            Write-Log "Saliendo. No se realizaron cambios."
            Read-Host "`nPresiona Enter para cerrar"
            exit 0
        }
    }
}

# 3. Elección de método de instalación
Write-Host "`n¿Cómo desea instalar Java?"
Write-Host "1) Portable (Descargar dentro de la carpeta del proyecto, no requiere admin)"
Write-Host "2) Global vía Instalador (Descarga y abre el instalador de Eclipse Temurin, requiere admin)"
Write-Host "3) Salir / Ya tengo Java instalado"
$installChoice = Read-Host "Opción [1-3]"

switch ($installChoice) {
    "1" {
        Write-Log "Iniciando instalación portable..."
        $installDir = Join-Path $projectRoot ".java_runtime"
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir | Out-Null
        }

        $url     = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/$javaType/hotspot/normal/eclipse?project=jdk"
        $zipFile = Join-Path $installDir "java.zip"

        Write-Log "Descargando Java 21 desde Adoptium... (esto puede tardar varios minutos dependiendo de tu conexión)"
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipFile -UseBasicParsing
        } catch {
            Write-Error-Custom "Error al descargar Java. Verifique su conexión a internet."
            Read-Host "`nPresiona Enter para cerrar"
            exit 1
        }

        Write-Log "Extrayendo archivos..."
        $tmpDir = Join-Path $installDir "tmp"
        if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
        New-Item -ItemType Directory -Path $tmpDir | Out-Null

        try {
            Expand-Archive -Path $zipFile -DestinationPath $tmpDir -Force
        } catch {
            Write-Error-Custom "Error al extraer los archivos de Java. Asegúrese de tener suficiente espacio en disco."
            Remove-Item -Recurse -Force $tmpDir -ErrorAction SilentlyContinue
            Remove-Item -Force $zipFile -ErrorAction SilentlyContinue
            Read-Host "`nPresiona Enter para cerrar"
            exit 1
        }

        $extractedDir = Get-ChildItem $tmpDir | Select-Object -First 1
        Move-Item -Path (Join-Path $extractedDir.FullName "*") -Destination $installDir -Force

        Remove-Item -Recurse -Force $tmpDir
        Remove-Item -Force $zipFile

        Write-Success "Java portable instalado correctamente en $installDir"
    }
    "2" {
        Write-Log "Iniciando descarga del instalador global... (esto puede tardar varios minutos)"
        $installerPath = Join-Path $env:TEMP "temurin-21-installer.msi"
        $msiUrl = "https://api.adoptium.net/v3/installer/latest/21/ga/windows/x64/$javaType/hotspot/normal/eclipse?project=jdk"

        try {
            Invoke-WebRequest -Uri $msiUrl -OutFile $installerPath -UseBasicParsing
        } catch {
            Write-Error-Custom "Error al descargar el instalador. Verifique su conexión a internet."
            Read-Host "`nPresiona Enter para cerrar"
            exit 1
        }

        Write-Log "El instalador de Java se abrirá a continuación."
        Write-Host "- Recomendado: instalar solo para su usuario (no para todos los usuarios de la máquina)" -ForegroundColor Yellow
        Write-Host "- Dejar todas las opciones por defecto" -ForegroundColor Yellow
        Write-Host "- Presionar 'Siguiente' hasta finalizar" -ForegroundColor Yellow
        try {
            $proc = Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`"" -Wait -PassThru
            if ($proc.ExitCode -ne 0) {
                Write-Error-Custom "El instalador terminó con un código de error: $($proc.ExitCode)."
                Read-Host "`nPresiona Enter para cerrar"
                exit 1
            }
            Write-Success "Instalación global completada con éxito."
        } catch {
            Write-Error-Custom "Error al ejecutar el instalador: $($_.Exception.Message)"
            Read-Host "`nPresiona Enter para cerrar"
            exit 1
        }
    }
    default {
        Write-Log "Saliendo de la configuración."
        Read-Host "`nPresiona Enter para cerrar"
        exit 0
    }
}

Write-Host "`nConfiguración finalizada con éxito." -ForegroundColor Green
Write-Host "Ahora puedes ejecutar el simulador usando los scripts correspondientes."
Read-Host "`nPresiona Enter para cerrar"