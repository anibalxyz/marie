@echo off
setlocal

:: MARIE Simulator - Script de Ejecución para Windows
:: Este script lanza el simulador utilizando el JAR generado.

:: 1. Determinar el comando de Java a usar
pushd "%~dp0..\.."
set "PROJECT_ROOT=%cd%"
popd

set "JAVA_CMD=java"
if exist "%PROJECT_ROOT%\.java_runtime\bin\java.exe" (
    echo [INFO] Usando Java portable (.java_runtime).
    set "JAVA_CMD=%PROJECT_ROOT%\.java_runtime\bin\java.exe"
) else (
    where java >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Usando Java del sistema.
    ) else (
        echo [ERROR] No se encontró Java. Por favor ejecute scripts\windows\setup.ps1 primero.
        exit /b 1
    )
)

:: 2. Verificar que exista el JAR
set "JAR_FILE=%PROJECT_ROOT%\target\marie.jar"
if not exist "%JAR_FILE%" (
    echo [ERROR] No se encontró el archivo %JAR_FILE%. Por favor ejecute scripts\windows\build.bat primero.
    exit /b 1
)

:: 3. Lanzar el simulador
echo [INFO] Iniciando MARIE Simulator...
"%JAVA_CMD%" -jar "%JAR_FILE%"

endlocal
