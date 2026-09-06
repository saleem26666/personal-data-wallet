@echo off
title Amanaat — Build APK
cd /d "%~dp0"
setlocal EnableDelayedExpansion

if exist "C:\Program Files\Git\cmd\git.exe" set "PATH=C:\Program Files\Git\cmd;%PATH%"
if exist "C:\Program Files (x86)\Git\cmd\git.exe" set "PATH=C:\Program Files (x86)\Git\cmd;%PATH%"

where flutter >nul 2>&1
if errorlevel 1 (
  for %%D in (
    "C:\flutter\bin"
    "D:\flutter\bin"
    "%LOCALAPPDATA%\flutter\bin"
    "%USERPROFILE%\flutter\bin"
    "%USERPROFILE%\develop\flutter\bin"
    "%USERPROFILE%\development\flutter\bin"
    "C:\src\flutter\bin"
    "C:\dev\flutter\bin"
    "D:\src\flutter\bin"
    "D:\dev\flutter\bin"
  ) do (
    if exist "%%~D\flutter.bat" (
      set "PATH=%%~D;%PATH%"
      goto :flutter_found
    )
  )
  echo [ERROR] Flutter nahi mila.
  echo Flutter SDK install karein, ya PATH me add karein.
  echo https://docs.flutter.dev/get-started/install/windows
  pause
  exit /b 1
)
:flutter_found

echo.
echo === Flutter ===
call flutter --version
if errorlevel 1 (
  echo [ERROR] Flutter chal nahi saka.
  pause
  exit /b 1
)

echo.
echo === pub get ===
call flutter pub get
if errorlevel 1 (
  echo [ERROR] flutter pub get fail.
  pause
  exit /b 1
)

echo.
echo === APK build ===
if /i "%~1"=="debug" (
  echo Debug APK — testing
  call flutter build apk --debug
) else if /i "%~1"=="split" (
  echo Split APKs: arm64 / arm32 / x86_64
  call flutter build apk --release --split-per-abi
) else if /i "%~1"=="fat" (
  echo Fat APK — ek file, sab phones
  call flutter build apk --release
) else if /i "%~1"=="clean" (
  echo Clean + arm64 release APK
  call flutter clean
  call flutter pub get
  call dart run build_runner build
  call flutter build apk --release --target-platform android-arm64
) else (
  echo Fast APK — sirf arm64 ^(aaj kal ke almost sab phones^)
  call flutter build apk --release --target-platform android-arm64
)

if errorlevel 1 (
  echo.
  echo [ERROR] APK build fail. Upar wala error check karein.
  pause
  exit /b 1
)

set "APK_DIR=%~dp0build\app\outputs\flutter-apk"
set "OUT_DIR=%~dp0apk"
if not exist "%OUT_DIR%" mkdir "%OUT_DIR%"

for /f "tokens=2" %%V in ('findstr /b /c:"version:" pubspec.yaml') do set "APP_VER=%%V"
set "APP_VER=%APP_VER:+=_%"

echo.
echo === Copy named APK ===
if exist "%APK_DIR%\app-release.apk" (
  copy /Y "%APK_DIR%\app-release.apk" "%OUT_DIR%\Amanaat-v%APP_VER%.apk" >nul
  copy /Y "%APK_DIR%\app-release.apk" "%OUT_DIR%\Amanaat-latest.apk" >nul
)
if exist "%APK_DIR%\app-debug.apk" (
  copy /Y "%APK_DIR%\app-debug.apk" "%OUT_DIR%\Amanaat-debug.apk" >nul
)
if exist "%APK_DIR%\app-arm64-v8a-release.apk" (
  copy /Y "%APK_DIR%\app-arm64-v8a-release.apk" "%OUT_DIR%\Amanaat-v%APP_VER%-arm64.apk" >nul
  copy /Y "%APK_DIR%\app-arm64-v8a-release.apk" "%OUT_DIR%\Amanaat-latest.apk" >nul
)

echo.
echo ========================================
echo  OK — APK ready
echo  Easy copy:  %OUT_DIR%
echo  Flutter:    %APK_DIR%
echo ========================================
echo.
if exist "%OUT_DIR%\*.apk" (
  dir /b "%OUT_DIR%\*.apk"
)
echo.
echo Phone pe Amanaat-latest.apk install karein.
echo.
echo Options:
echo   build_apk.bat         = tez arm64 release ^(default^)
echo   build_apk.bat debug   = debug APK
echo   build_apk.bat split   = arm64 + arm32 + x86_64 alag files
echo   build_apk.bat fat     = 1 bari APK sab phones ke liye
echo   build_apk.bat clean   = flutter clean ke baad naya build
echo.

if exist "%OUT_DIR%" explorer "%OUT_DIR%"
pause
endlocal
