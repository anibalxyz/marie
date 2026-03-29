@echo off
setlocal

:: MARIE Simulator - Script de Compilación para Windows
:: Este script utiliza el Maven Wrapper para compilar el proyecto.

echo [INFO] Configurando entorno de compilación...

:: 1. Detección de Java (JDK con prioridad)
pushd "%~dp0..\.."
set "PROJECT_ROOT=%cd%"
popd
set "PORTABLE_JDK=%PROJECT_ROOT%\.java_runtime\bin\javac.exe"

if exist "%PORTABLE_JDK%" (
    echo [INFO] Se utilizará el JDK portable (.java_runtime).
    set "JAVA_HOME=%PROJECT_ROOT%\.java_runtime"
    set "PATH=%JAVA_HOME%\bin;%PATH%"
) else (
    where javac >nul 2>&1
    if %errorlevel% equ 0 (
        echo [INFO] Se utilizará el JDK instalado globalmente en el sistema.
    ) else (
        echo [ERROR] No se encontró un JDK (javac). Se requiere para compilar.
        echo [ERROR] Por favor ejecute scripts\windows\setup.ps1 y elija instalar el JDK.
        exit /b 1
    )
)

:: 2. Compilar
echo [INFO] Iniciando compilación con Maven Wrapper...
call "%PROJECT_ROOT%\mvnw.cmd" -f "%PROJECT_ROOT%\pom.xml" clean package

if %errorlevel% equ 0 (
    echo [OK] Compilación exitosa. El archivo se encuentra en target\marie.jar
) else (
    echo [ERROR] La compilación falló.
    exit /b 1
)

endlocal
