@echo off
setlocal enabledelayedexpansion

:: ==============================================
:: Samsung Browser Portable - Update Script
:: Cập nhật lên phiên bản mới nhất
:: ==============================================

title Samsung Browser Portable - Update
color 1f

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "CHROME_BIN=%SCRIPT_DIR%\Chrome-bin"
set "DATA_DIR=%SCRIPT_DIR%\Data"
set "CACHE_DIR=%SCRIPT_DIR%\Cache"
set "TEMP_DIR=%SCRIPT_DIR%\temp"
set "WIDEVINE_DIR=%SCRIPT_DIR%\WidevineCdm"

echo ================================================
echo   Samsung Browser Portable - Update Script
echo ================================================
echo.

:: Kiểm tra phiên bản hiện tại
set "CURRENT_VERSION="
if exist "%SCRIPT_DIR%\version.txt" (
    set /p CURRENT_VERSION=<"%SCRIPT_DIR%\version.txt"
    echo [INFO] Phien ban hien tai: %CURRENT_VERSION%
) else (
    echo [ERROR] Khong tim thay file version.txt
    echo Vui long chay build.bat de cai dat lan dau!
    pause
    exit /b 1
)

:: Tạo thư mục tạm
if not exist "%TEMP_DIR%" mkdir "%TEMP_DIR%"

echo.
echo Dang kiem tra phien ban moi nhat...

:: Lấy thông tin từ GitHub
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/hoangxg4/samsung_browser-offline-installer/releases/latest' -UserAgent 'SamsungBrowser').assets ^| Where-Object { $_.name -match 'SamsungInternet_Offline' } ^| Select-Object -First 1 ^| ForEach-Object { $_.browser_download_url + '|' + $_.name }"') do set "DOWNLOAD_INFO=%%i"

if not defined DOWNLOAD_INFO (
    echo [ERROR] Khong the kiem tra phien ban moi
    pause
    exit /b 1
)

for /f "tokens=1,2 delims=|" %%a in ("%DOWNLOAD_INFO%") do (
    set "DOWNLOAD_URL=%%a"
    set "FILENAME=%%b"
)

echo [INFO] File moi: %FILENAME%

:: Trích xuất phiên bản từ tên file
set "NEW_VERSION=%FILENAME:SamsungInternet_Offline_v=%"
set "NEW_VERSION=%NEW_VERSION:.zip=%"

echo [INFO] Phien ban moi: %NEW_VERSION%

:: So sánh
if "%CURRENT_VERSION%"=="%NEW_VERSION%" (
    echo.
    echo [INFO] Ban dang su dung phien ban moi nhat!
    pause
    exit /b 0
)

echo.
echo [1/3] Dang tai phien ban moi...
echo.

:: Tải file
set "ZIP_FILE=%TEMP_DIR%\%FILENAME%"
powershell -Command "Invoke-WebRequest -Uri '%DOWNLOAD_URL%' -OutFile '%ZIP_FILE%' -UserAgent 'SamsungBrowser'"

echo.
echo [2/3] Dang giai nen...

:: Giải nén
set "EXTRACT_DIR=%TEMP_DIR%\update"
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
mkdir "%EXTRACT_DIR%"

powershell -Command "Expand-Archive -Path '%ZIP_FILE%' -DestinationPath '%EXTRACT_DIR%' -Force"

:: Tìm mini_installer.exe
set "MINI_INSTALLER="
for /r "%EXTRACT_DIR%" %%f in (mini_installer.exe) do (
    set "MINI_INSTALLER=%%f"
    goto :found_mini
)

:found_mini
if not defined MINI_INSTALLER (
    echo [ERROR] Khong tim thay mini_installer.exe
    pause
    exit /b 1
)

echo [INFO] Tim thay: %MINI_INSTALLER%

:: Giải nén mini_installer
echo [INFO] Dang giai nen installer...
start /wait /b cmd /c "%MINI_INSTALLER% /s /d"%TEMP_DIR%""
timeout /t 10 /nobreak >nul

:: Tìm samsunginternet.7z
set "SEVEN_ZIP="
for %%f in ("%TEMP_DIR%\samsunginternet.7z") do (
    if exist "%%f" set "SEVEN_ZIP=%%f"
)

:: Nếu không tìm thấy, thử tìm trong thư mục khác
if not defined SEVEN_ZIP (
    for /r "%TEMP_DIR%" %%f in (samsunginternet.7z) do (
        set "SEVEN_ZIP=%%f"
    )
)

if not defined SEVEN_ZIP (
    echo [ERROR] Khong tim thay samsunginternet.7z
    echo Vui long cai dat 7-Zip va thu lai!
    pause
    exit /b 1
)

echo [INFO] Tim thay: %SEVEN_ZIP%

:: Giải nén 7z
echo [INFO] Dang giai nen Chrome-bin...

:: Xóa Chrome-bin cũ
if exist "%CHROME_BIN%" rmdir /s /q "%CHROME_BIN%"

:: Thử dùng 7-Zip
set "SEVENZIP=C:\Program Files\7-Zip\7z.exe"
if not exist "%SEVENZIP%" set "SEVENZIP=%ProgramFiles(x86)%\7-Zip\7z.exe"

if exist "%SEVENZIP%" (
    "%SEVENZIP%" x "%SEVEN_ZIP%" "-o%CHROME_BIN%" -y >nul 2>&1
) else (
    echo [ERROR] Can cai dat 7-Zip de giai nen
    echo Tai tai: https://www.7-zip.org/
    pause
    exit /b 1
)

:: Cài đặt lại Widevine
if exist "%WIDEVINE_DIR%" (
    echo.
    echo [3/3] Dang cai dat Widevine...
    
    :: Tìm file exe chính
    for /r "%CHROME_BIN%" %%f in (samsunginternet.exe) do (
        set "MAIN_EXE=%%f"
        goto :found_exe
    )
    
    :found_exe
    if defined MAIN_EXE (
        set "WIDEVINE_DEST=!MAIN_EXE!\..\WidevineCdm"
        if not exist "!WIDEVINE_DEST!" (
            xcopy /e /y "%WIDEVINE_DIR%" "!WIDEVINE_DEST!" >nul
        )
    )
)

:: Cập nhật version.txt
echo %NEW_VERSION% > "%SCRIPT_DIR%\version.txt"

:: Dọn dẹp
if exist "%ZIP_FILE%" del "%ZIP_FILE%"
if exist "%EXTRACT_DIR%" rmdir /s /q "%EXTRACT_DIR%"
if exist "%SEVEN_ZIP%" del "%SEVEN_ZIP%"

echo.
echo ================================================
echo   Cap nhat hoan tat!
echo ================================================
echo.
echo Phien ban cu: %CURRENT_VERSION%
echo Phien ban moi: %NEW_VERSION%
echo.
echo Du lieu nguoi dung trong Data/ duoc giu nguyen!
echo.
pause
