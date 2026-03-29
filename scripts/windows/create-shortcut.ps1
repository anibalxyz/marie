# MARIE Simulator - Generador de Acceso Directo para Windows
# Este script crea un acceso directo (.lnk) en el escritorio para lanzar el simulador.

$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Log($msg) {
    Write-Host "[INFO] $msg" -ForegroundColor Blue
}

function Write-Success($msg) {
    Write-Host "[OK] $msg" -ForegroundColor Green
}

function Write-Error-Custom($msg) {
    Write-Host "[ERROR] $msg" -ForegroundColor Red
}

Write-Host "==================================================" -ForegroundColor Blue
Write-Host "   Generador de Acceso Directo MARIE Simulator    " -ForegroundColor Blue
Write-Host "==================================================" -ForegroundColor Blue

# 1. Rutas
$projectRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
$execPath = Join-Path $projectRoot "scripts\windows\run.bat"
$iconPath = Join-Path $projectRoot "src\main\resources\M.ico"
$shortcutPath = Join-Path ([Environment]::GetFolderPath("Desktop")) "MARIE Simulator.lnk"

# 2. Verificar que run.bat existe
if (-not (Test-Path $execPath)) {
    Write-Error-Custom "No se encontró run.bat en $execPath."
    exit 1
}

# 3. Crear el acceso directo usando COM
Write-Log "Generando acceso directo en el escritorio..."

try {
    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = "cmd.exe"
    $shortcut.Arguments = "/c `"$execPath`""
    $shortcut.WorkingDirectory = $projectRoot
    $shortcut.IconLocation = $iconPath
    $shortcut.WindowStyle = 7
    $shortcut.Description = "Simulador de arquitectura MARIE"
    $shortcut.Save()
    Write-Success "Acceso directo creado correctamente en el escritorio."
} catch {
    Write-Error-Custom "Error al crear el acceso directo: $($_.Exception.Message)"
    exit 1
}

Write-Host "`nProceso finalizado." -ForegroundColor Green
