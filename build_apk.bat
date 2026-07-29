@echo off
title GVS 365 LG Mobile App - APK Builder
echo ========================================================
echo        GVS 365 LG MOBILE APP - APK COMPILER
echo ========================================================
echo.

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [WARNING] Flutter SDK is not detected in your PATH environment variable.
    echo.
    echo If Flutter is installed, please add its bin path to PATH.
    echo Otherwise, push this repository to GitHub or use GitHub Actions 
    echo workflow to compile the APK on Cloud Runners.
    echo.
    pause
    exit /b 1
)

echo [1/3] Fetching Flutter dependencies...
call flutter pub get

echo.
echo [2/3] Building Release Android APK...
call flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo ========================================================
    echo SUCCESS! APK Generated Successfully:
    echo Location: build\app\outputs\flutter-apk\app-release.apk
    echo ========================================================
    copy build\app\outputs\flutter-apk\app-release.apk gvs_365_lg_app.apk >nul 2>nul
    echo Copied to root folder as: gvs_365_lg_app.apk
) else (
    echo [ERROR] Build failed. Please check Flutter and Android SDK settings.
)

echo.
pause
