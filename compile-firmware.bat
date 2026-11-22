@echo off
setlocal EnableExtensions
cd /d "%~dp0"

rem Usage:
rem   compile-firmware.bat [Preset] [extra CMake options]
rem Presets: Custom, Fusion, Service, All

set "PRESET=%~1"
if not defined PRESET set "PRESET=Fusion"
if not "%~1"=="" shift

if /I "%PRESET%"=="all" set "PRESET=All"
if /I not "%PRESET%"=="Custom" if /I not "%PRESET%"=="Fusion" if /I not "%PRESET%"=="Service" if /I not "%PRESET%"=="All" (
    echo Unknown preset: "%PRESET%"
    echo Valid presets are: Custom, Fusion, Service, All
    exit /b 1
)

if /I "%PRESET%"=="custom" set "PRESET=Custom"
if /I "%PRESET%"=="fusion" set "PRESET=Fusion"
if /I "%PRESET%"=="service" set "PRESET=Service"

set "EXTRA_ARGS="
:collect_args
if "%~1"=="" goto args_done
set EXTRA_ARGS=%EXTRA_ARGS% "%~1"
shift
goto collect_args
:args_done

where cmake >nul 2>&1
if errorlevel 1 (
    echo CMake was not found. Install CMake 3.24 or newer and add it to PATH.
    exit /b 1
)

where ninja >nul 2>&1
if errorlevel 1 (
    echo Ninja was not found. Install Ninja and add it to PATH.
    exit /b 1
)

where python >nul 2>&1
if errorlevel 1 (
    echo Python 3 was not found. Install Python 3 and add it to PATH.
    exit /b 1
)
python -c "import sys; sys.exit(0 if sys.version_info[0] == 3 else 1)" >nul 2>&1
if errorlevel 1 (
    echo The "python" command does not run Python 3. Install Python 3 and add it to PATH.
    exit /b 1
)

rem The official Windows installer does not always add its bin directory to PATH.
if defined ProgramFiles(x86) (
    for /d %%D in ("%ProgramFiles(x86)%\Arm GNU Toolchain arm-none-eabi\*") do (
        if exist "%%~fD\bin\arm-none-eabi-gcc.exe" set "PATH=%%~fD\bin;%PATH%"
    )
)
where arm-none-eabi-gcc >nul 2>&1
if errorlevel 1 (
    echo GNU Arm Embedded Toolchain was not found.
    echo Install the Arm GNU Toolchain for arm-none-eabi and add its bin folder to PATH.
    exit /b 1
)

echo Native Windows firmware build tools:
cmake --version
ninja --version
arm-none-eabi-gcc --version

if /I "%PRESET%"=="All" (
    call :build_preset Fusion
    if errorlevel 1 exit /b 1
    call :build_preset Service
    if errorlevel 1 exit /b 1
    echo.
    echo All presets built successfully!
    exit /b 0
)

call :build_preset "%PRESET%"
exit /b %errorlevel%

:build_preset
set "CURRENT_PRESET=%~1"
set "PRESET_SLUG=%CURRENT_PRESET%"
if /I "%CURRENT_PRESET%"=="Custom" set "PRESET_SLUG=custom"
if /I "%CURRENT_PRESET%"=="Fusion" set "PRESET_SLUG=fusion"
if /I "%CURRENT_PRESET%"=="Service" set "PRESET_SLUG=service"

echo.
echo === Building preset: %CURRENT_PRESET% ===
echo ---------------------------------------------

cmake --fresh --preset "%CURRENT_PRESET%" %EXTRA_ARGS%
if errorlevel 1 (
    echo.
    echo Configuration failed: %CURRENT_PRESET%
    exit /b 1
)

cmake --build --preset "%CURRENT_PRESET%" --parallel
if errorlevel 1 (
    echo.
    echo Build failed: %CURRENT_PRESET%
    exit /b 1
)

set "BIN_FILE=build\%CURRENT_PRESET%\f4hwn.%PRESET_SLUG%.bin"
if not exist "%BIN_FILE%" (
    echo.
    echo Expected binary not found: %BIN_FILE%
    exit /b 1
)

echo.
echo Done: %CURRENT_PRESET%
echo Output: %BIN_FILE%
exit /b 0
