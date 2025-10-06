@echo off
REM Czech (czenglish) Keyboard Layout - Quick Installer for Windows
REM (C) 2025 Tomas Mark

echo ====================================================
echo Czech (czenglish) Keyboard Layout Installer
echo ====================================================
echo.

REM Check for admin privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script requires Administrator privileges!
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

echo [INFO] Checking for Microsoft Keyboard Layout Creator...
echo.

set "MSKLC_PATH_1=%ProgramFiles(x86)%\Microsoft Keyboard Layout Creator 1.4\MSKLC.exe"
set "MSKLC_PATH_2=%ProgramFiles%\Microsoft Keyboard Layout Creator 1.4\MSKLC.exe"

if exist "%MSKLC_PATH_1%" (
    echo [OK] MSKLC found!
    goto :find_setup
)
if exist "%MSKLC_PATH_2%" (
    echo [OK] MSKLC found!
    goto :find_setup
)

echo [WARNING] Microsoft Keyboard Layout Creator NOT found!
echo.
echo Please download and install MSKLC from:
echo https://www.microsoft.com/en-us/download/details.aspx?id=102134
echo.
echo After installing MSKLC:
echo   1. Open MSKLC
echo   2. Load czenglish.klc (File -^> Load Source File)
echo   3. Build setup (Project -^> Build DLL and Setup Package)
echo   4. Run the generated setup.exe
echo.
pause
exit /b 1

:find_setup
echo [INFO] Looking for compiled setup package...
echo.

if exist "czenglish\setup.exe" (
    set "SETUP_PATH=czenglish\setup.exe"
    goto :install
)
if exist "czenglish_amd64\setup.exe" (
    set "SETUP_PATH=czenglish_amd64\setup.exe"
    goto :install
)
if exist "czenglish_i386\setup.exe" (
    set "SETUP_PATH=czenglish_i386\setup.exe"
    goto :install
)

echo [INFO] Setup package not found. You need to compile it first:
echo.
echo Steps:
echo   1. Open Microsoft Keyboard Layout Creator
echo   2. Load czenglish.klc: File -^> Load Source File
echo   3. Build installer: Project -^> Build DLL and Setup Package
echo   4. Run this script again
echo.
echo The setup will be created in a subfolder named 'czenglish'
echo.
pause
exit /b 0

:install
echo [OK] Found setup at: %SETUP_PATH%
echo.
echo Starting installation...
echo.

start /wait "" "%SETUP_PATH%"

if %errorLevel% equ 0 (
    echo.
    echo [OK] Installation completed successfully!
    echo.
    echo Next steps:
    echo   1. Restart your computer (or log out and back in^)
    echo   2. Open Settings -^> Time ^& Language -^> Language ^& region
    echo   3. Click Czech -^> Options -^> Add a keyboard
    echo   4. Select 'Czech (czenglish^)'
    echo   5. Use Windows + Space to switch between layouts
    echo.
) else (
    echo.
    echo [ERROR] Installation may have failed or was cancelled.
    echo Please check the setup logs and try again.
    echo.
)

pause
