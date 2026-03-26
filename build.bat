@echo off
setlocal enabledelayedexpansion

:: ==============================================
:: Samsung Browser Portable - Build Script
:: Tải và cài đặt Samsung Browser Offline
:: ==============================================

title Samsung Browser Portable - Build Script
color 1f

:: Đường dẫn thư mục
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "CHROME_BIN=%SCRIPT_DIR%\Chrome-bin"
set "DATA_DIR=%SCRIPT_DIR%\Data"
set "CACHE_DIR=%SCRIPT_DIR%\Cache"
set "WIDEVINE_DIR=%SCRIPT_DIR%\WidevineCdm"
set "TEMP_DIR=%SCRIPT_DIR%\temp"

echo ================================================
echo   Samsung Browser Portable - Build Script
echo ================================================
echo.

:: Kiểm tra phiên bản hiện tại
set "CURRENT_VERSION="
if exist "%SCRIPT_DIR%\version.txt" (
    set /p CURRENT_VERSION=<"%SCRIPT_DIR%\version.txt"
    echo [INFO] Phien ban hien tai: %CURRENT_VERSION%
) else (
    echo [INFO] Chua co phien ban nao duoc cai dat
)

:: Tạo thư mục tạm
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo [1/4] Dang tai Samsung Browser Offline...
echo.

:: Tải file từ GitHub release (phiên bản mới nhất)
:: Lấy thông tin từ GitHub API
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/hoangxg4/samsung_browser-offline-installer/releases/latest' -UserAgent 'SamsungBrowser').assets ^| Where-Object { $_.name -match 'SamsungInternet_Offline' } ^| Select-Object -First 1 ^| ForEach-Object { $_.browser_download_url }"') do set "DOWNLOAD_URL=%%i"

if not defined DOWNLOAD_URL (
    echo [WARNING] Khong the lay link tu GitHub, thu dung link mac dinh...
    set "DOWNLOAD_URL=https://github.com/hoangxg4/samsung_browser-offline-installer/releases/download/v143.0.0.95/SamsungInternet_Offline_v143.0.0.95.zip"
)

echo [INFO] Link tai: %DOWNLOAD_URL%
echo.

:: Tải file
set "ZIP_FILE=%TEMP_DIR%\samsung_offline.zip"
echo [2/4] Dang tai file...
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' -UserAgent 'SamsungBrowser'"


