@echo off

:: ==============================================
:: Samsung Browser Portable - Install Widevine
:: Cài đặt Widevine DRM vào Samsung Browser
:: ==============================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "WIDEVINE_SRC=%SCRIPT_DIR%\WidevineCdm"
set "CHROME_BIN=%SCRIPT_DIR%\Chrome-bin"

echo ================================================
echo   Samsung Browser - Install Widevine DRM
echo ================================================
echo.

:: Kiểm tra thư mục Widevine gốc
if not exist "%WIDEVINE_SRC%" (
    echo [ERROR] Khong tim thay thu muc WidevineCdm
    pause
    exit /b 1
)

:: Kiểm tra Chrome-bin
if not exist "%CHROME_BIN%" (
    echo [ERROR] Chua cai dat Samsung Browser!
    echo Vui long chay build.bat de cai dat!
    pause
    exit /b 1
)

:: Tìm file exe chính
set "MAIN_EXE="
for /r "%CHROME_BIN%" %%f in (samsunginternet.exe) do (
    set "MAIN_EXE=%%f"
    goto :found_exe
)

:found_exe
if not defined MAIN_EXE (
    echo [ERROR] Khong tim thay samsunginternet.exe
    pause
    exit /b 1
)

echo [INFO] File exe: %MAIN_EXE%

:: Tạo thư mục WidevineCdm trong thư mục browser
set "WIDEVINE_DEST=%MAIN_EXE%\..\WidevineCdm"

:: Kiểm tra nếu đã cài đặt
if exist "%WIDEVINE_DEST%" (
    echo [INFO] Widevine da duoc cai dat!
    choice /c YN /m "Ban co muon cai lai khong?"
    if errorlevel 2 goto :end
    
    rmdir /s /q "%WIDEVINE_DEST%"
)

echo.
echo [1/1] Dang cai dat Widevine...

:: Copy Widevine
xcopy /e /y "%WIDEVINE_SRC%" "%WIDEVINE_DEST%" >nul 2>&1

if exist "%WIDEVINE_DEST%" (
    echo.
    echo ================================================
    echo   Cai dat hoan tat!
    ================================================
    echo.
    echo [OK] Widevine da duoc cai dat vao:
    echo     %WIDEVINE_DEST%
    echo.
    echo Ban co the su dung Netflix, Disney+, Spotify, etc.
) else (
    echo.
    echo [ERROR] Loi khi cai dat Widevine
)

:end
pause
