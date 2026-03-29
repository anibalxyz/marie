# MARIE Simulator - Script de Compilación para Windows
# Este script utiliza el Maven Wrapper para compilar el proyecto.

function Write-Log($msg)          { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Success($msg)      { Write-Host "[OK] $msg" -ForegroundColor Green }
function Write-Error-Custom($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

$projectRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName

Write-Log "Configurando entorno de compilación..."

# 1. Detección de Java (JDK con prioridad)
$portableJavac = Join-Path $projectRoot ".java_runtime\bin\javac.exe"

if (Test-Path $portableJavac) {
    Write-Log "Se utilizará el JDK portable (.java_runtime)."
    $env:JAVA_HOME = Join-Path $projectRoot ".java_runtime"
    $env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
} elseif (Get-Command javac -ErrorAction SilentlyContinue) {
    Write-Log "Se utilizará el JDK instalado globalmente en el sistema."
} else {
    Write-Error-Custom "No se encontró un JDK (javac). Se requiere para compilar."
    Write-Error-Custom "Por favor ejecute scripts\windows\setup.ps1 y elija instalar el JDK."
    Read-Host "`nPresiona Enter para cerrar"
    exit 1
}

# 2. Compilar
Write-Log "Iniciando compilación con Maven Wrapper..."
& "$projectRoot\mvnw.cmd" -f "$projectRoot\pom.xml" clean package

if ($LASTEXITCODE -eq 0) {
    Write-Success "Compilación exitosa. El archivo se encuentra en target\marie.jar"
} else {
    Write-Error-Custom "La compilación falló."
}

Read-Host "`nPresiona Enter para cerrar"
