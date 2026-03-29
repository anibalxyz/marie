# MARIE Simulator - Script de Ejecución para Windows
# Este script lanza el simulador utilizando el JAR generado.

function Write-Log($msg)          { Write-Host "[INFO] $msg" -ForegroundColor Blue }
function Write-Error-Custom($msg) { Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Get-ProjectRoot {
    return (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
}

function Get-JavawCmd {
    $projectRoot   = Get-ProjectRoot
    $portableJavaw = Join-Path $projectRoot ".java_runtime\bin\javaw.exe"

    if (Test-Path $portableJavaw) {
        Write-Log "Usando javaw portable (.java_runtime)."
        return $portableJavaw
    } elseif (Get-Command javaw -ErrorAction SilentlyContinue) {
        Write-Log "Usando javaw del sistema."
        return "javaw"
    } else {
        Write-Error-Custom "No se encontró javaw. Por favor ejecute scripts\windows\setup.ps1 primero."
        return $null
    }
}

function Get-JarPath {
    $jarFile = Join-Path (Get-ProjectRoot) "target\marie.jar"
    if (Test-Path $jarFile) {
        return $jarFile
    } else {
        Write-Error-Custom "No se encontró marie.jar. Por favor ejecute scripts\windows\build.ps1 primero."
        return $null
    }
}

function Assert-CanRun {
    $script:javawCmd = Get-JavawCmd
    if (-not $script:javawCmd) {
        Read-Host "`nPresiona Enter para cerrar"
        exit 1
    }

    $script:jarFile = Get-JarPath
    if (-not $script:jarFile) {
        Read-Host "`nPresiona Enter para cerrar"
        exit 1
    }
}

function Start-Marie {
    Assert-CanRun
    Write-Log "Iniciando MARIE Simulator..."
    & $script:javawCmd -jar $script:jarFile
}

if ($MyInvocation.InvocationName -ne '.') {
    Start-Marie
}
