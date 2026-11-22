@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem Usage:
rem   compile-app.bat
rem   compile-app.bat All
rem   compile-app.bat breakout
rem   compile-app.bat cwkeyer cwusb cwmem

docker version >nul 2>&1
if errorlevel 1 (
    echo Docker is not available. Start Docker Desktop and try again.
    exit /b 1
)

set "IMAGE=uvk1-uvk5v3"
docker images -q "%IMAGE%" | findstr "." >nul 2>&1
if errorlevel 1 (
    echo Building Docker image...
    docker build -q -t "%IMAGE%" .
    if errorlevel 1 (
        echo Docker image build failed.
        exit /b 1
    )
)

set "APP_ARGS="
:collect_args
if "%~1"=="" goto args_done
set "APP_ARGS=%APP_ARGS% "%~1""
shift
goto collect_args
:args_done

docker run --rm -e MSYS_NO_PATHCONV=1 -v "%CD%:/src" -w /src "%IMAGE%" bash ./compile-app.sh%APP_ARGS%
exit /b %errorlevel%
