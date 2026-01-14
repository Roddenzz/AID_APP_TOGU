@echo off
REM Quick Start Script for TOGU Aid App (Windows)

setlocal enabledelayedexpansion

cls
echo ============================================
echo    TOGU Aid App - Quick Start (Windows)
echo ============================================
echo.

REM Check Flutter installation
echo [1/5] Checking Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Error: Flutter not found
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo [OK] Flutter found
flutter --version
echo.

REM Navigate to project
echo [2/5] Setting up project directory...
if not exist "aid_app" (
    echo Error: aid_app directory not found
    echo Please navigate to the project directory first
    pause
    exit /b 1
)

cd /d aid_app
echo [OK] Project directory ready
echo.

REM Clean and get dependencies
echo [3/5] Installing dependencies...
call flutter clean
call flutter pub get
echo [OK] Dependencies installed
echo.

REM Check for devices
echo [4/5] Checking for connected devices...
call flutter devices
echo.

REM Display instructions
echo [5/5] Setup complete!
echo.
echo ============================================
echo        NEXT STEPS
echo ============================================
echo.
echo To run on device:
echo   flutter run
echo.
echo To build Android release:
echo   flutter build apk --release
echo.
echo To build Windows release:
echo   flutter build windows --release
echo.
echo To run tests:
echo   flutter test
echo.
echo To analyze code:
echo   flutter analyze
echo.
echo IMPORTANT: Configure staff users in:
echo   lib\services\database_service.dart
echo.
echo For more information, see:
echo   - README.md - Project overview
echo   - INSTALL.md - Installation guide
echo   - BUILD.md - Build instructions
echo   - PROJECT_SUMMARY.md - What's been created
echo.
pause
