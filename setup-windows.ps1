# MARIE Simulator - Script de Configuración para Windows
# Este script ayuda a instalar Java (JRE o JDK) de forma portable o global.

$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Blue
}

function Write-Success($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Warn($msg) {
    Write-Host "[ADVERTENCIA] $msg" -ForegroundColor Yellow
}

function Write-Error-Custom($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

Write-Host "==================================================" -ForegroundColor Blue
Write-Host "   Configuración de Entorno MARIE Simulator       " -ForegroundColor Blue
Write-Host "==================================================" -ForegroundColor Blue

# 0. Verificar si Java 21+ ya está instalado
$javaPath = Get-Command java -ErrorAction SilentlyContinue
if ($javaPath) {
    $javaVersionOutput = & java -version 2>&1 | Out-String
    if ($javaVersionOutput -match 'version "(\d+)') {
        $version = [int]$Matches[1]
        if ($version -ge 21) {
            Write-Success "Se detectó Java versión $version ya instalado en su sistema."
            Write-Host "¿Desea continuar con la instalación de todas formas?"
            Write-Host "1) Sí, continuar"
            Write-Host "2) No, salir"
            $choice = Read-Host "Opción [1-2]"
            if ($choice -ne "1") {
                Write-Log "Saliendo. No se realizaron cambios."
                exit 0
            }
        }
    }
}

# 1. Elección entre JRE y JDK
Write-Host "`nSeleccione qué desea instalar:"
Write-Host "1) JRE (Solo para ejecutar el simulador)"
Write-Host "2) JDK (Para ejecutar y también compilar/desarrollar)"
$typeChoice = Read-Host "Opción [1-2]"

if ($typeChoice -eq "2") {
    $javaType = "jdk"
    Write-Log "Has seleccionado instalar un JDK."
} else {
    $javaType = "jre"
    Write-Log "Has seleccionado instalar un JRE."
}

# 2. Elección de método de instalación
Write-Host "`n¿Cómo desea instalar Java?"
Write-Host "1) Portable (Descargar dentro de la carpeta del proyecto, no requiere admin)"
Write-Host "2) Global vía Instalador (Descarga y abre el instalador de Eclipse Temurin, requiere admin)"
Write-Host "3) Salir / Ya tengo Java instalado"
$installChoice = Read-Host "Opción [1-3]"

switch ($installChoice) {
    "1" {
        # Instalación Portable
        Write-Log "Iniciando instalación portable..."
        $installDir = Join-Path (Get-Location) ".java_runtime"
        if (-not (Test-Path $installDir)) {
            New-Item -ItemType Directory -Path $installDir | Out-Null
        }

        # URL de Eclipse Temurin 21 (Windows x64)
        $url = "https://api.adoptium.net/v3/binary/latest/21/ga/windows/x64/$javaType/hotspot/normal/eclipse?project=jdk"
        $zipFile = Join-Path $installDir "java.zip"

        Write-Log "Descargando Java 21 desde Adoptium..."
        try {
            Invoke-WebRequest -Uri $url -OutFile $zipFile
        } catch {
            Write-Error-Custom "Error al descargar Java. Verifique su conexión a internet."
            exit 1
        }

        Write-Log "Extrayendo archivos..."
        $tmpDir = Join-Path $installDir "tmp"
        if (Test-Path $tmpDir) { Remove-Item -Recurse -Force $tmpDir }
        New-Item -ItemType Directory -Path $tmpDir | Out-Null
        
        try {
            Expand-Archive -Path $zipFile -DestinationPath $tmpDir
        } catch {
            Write-Error-Custom "Error al extraer los archivos de Java. Asegúrese de tener suficiente espacio en disco."
            exit 1
        }

        $extractedDir = Get-ChildItem $tmpDir | Select-Object -First 1
        $sourcePath = Join-Path $extractedDir.FullName "*"
        Move-Item -Path $sourcePath -Destination $installDir -Force
        
        Remove-Item -Recurse -Force $tmpDir
        Remove-Item -Force $zipFile
        
        Write-Success "Java portable instalado correctamente en $installDir"
    }
    "2" {
        # Instalación Global
        Write-Log "Iniciando descarga del instalador global..."
        $installerPath = Join-Path $env:TEMP "temurin-21-installer.msi"
        $msiUrl = "https://api.adoptium.net/v3/installer/latest/21/ga/windows/x64/$javaType/hotspot/normal/eclipse?project=jdk"
        
        try {
            Invoke-WebRequest -Uri $msiUrl -OutFile $installerPath
        } catch {
            Write-Error-Custom "Error al descargar el instalador. Verifique su conexión a internet."
            exit 1
        }

        Write-Log "El instalador de Java se abrirá a continuación. Por favor, siga los pasos en pantalla."
        Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`"" -Wait
        Write-Success "Proceso del instalador finalizado."
    }
    Default {
        Write-Log "Saliendo de la configuración."
        exit 0
    }
}

Write-Host "`nConfiguración finalizada con éxito." -ForegroundColor Green
Write-Host "Ahora puedes ejecutar el simulador usando los scripts correspondientes."
