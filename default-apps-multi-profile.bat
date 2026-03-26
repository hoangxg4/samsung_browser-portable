@echo off
setlocal

:: ==============================================
:: CONFIGURATION SECTION - ĐÃ CHỈNH CHO SAMSUNG
:: ==============================================
:: File này nên đặt trong thư mục Samsung_Browser (cùng cấp với samsunginternet.exe)
set "app=%~dp0"
set "CHROMIUM_PATH=%app%samsunginternet.exe"
set "PROFILE_PATH=%app%Data"
set "BROWSER_NAME=Samsung Internet Portable"
set "BROWSER_DESC=Samsung Internet Browser with custom portable profile"

:: ==============================================
:: SYSTEM CHECKS
:: ==============================================
:: Kiểm tra quyền Admin
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    ECHO Dang yeu cau quyen Administrator...
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    EXIT /B
)

:: Kiểm tra file thực thi Samsung Internet
if not exist "%CHROMIUM_PATH%" (
    echo [ERROR] Khong tim thay samsunginternet.exe tai:
    echo "%CHROMIUM_PATH%"
    echo.
    echo Hay dam bao file .bat nay nam trong thu muc Samsung_Browser.
    pause
    exit /b 1
)

:: Tạo thư mục Data nếu chưa có
if not exist "%PROFILE_PATH%" (
    echo [WARNING] Dang tao thu muc Data...
    mkdir "%PROFILE_PATH%"
)

:: ==============================================
:: REGISTRY CONFIGURATION
:: ==============================================
echo Dang dang ky Samsung Internet vao Windows Registry...

:: Xóa cấu hình cũ (nếu có)
reg delete "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%" /f >nul 2>&1
reg delete "HKLM\Software\Classes\%BROWSER_NAME%HTML" /f >nul 2>&1
reg delete "HKLM\Software\Classes\%BROWSER_NAME%URL" /f >nul 2>&1

:: Đăng ký khả năng của trình duyệt
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%" /ve /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Đăng ký liên kết file (HTML, HTM)
reg add "HKLM\Software\Classes\%BROWSER_NAME%HTML" /ve /d "%BROWSER_NAME% Document" /f
reg add "HKLM\Software\Classes\%BROWSER_NAME%HTML\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Classes\%BROWSER_NAME%HTML\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Đăng ký giao thức URL (http, https)
reg add "HKLM\Software\Classes\%BROWSER_NAME%URL" /ve /d "%BROWSER_NAME% URL" /f
reg add "HKLM\Software\Classes\%BROWSER_NAME%URL" /v "URL Protocol" /d "" /f
reg add "HKLM\Software\Classes\%BROWSER_NAME%URL\DefaultIcon" /ve /d "\"%CHROMIUM_PATH%\",0" /f
reg add "HKLM\Software\Classes\%BROWSER_NAME%URL\shell\open\command" /ve /d "\"%CHROMIUM_PATH%\" --user-data-dir=\"%PROFILE_PATH%\" \"%%1\"" /f

:: Thiết lập Capabilities
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /v "ApplicationDescription" /d "%BROWSER_DESC%" /f

:: Liên kết đuôi file
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".htm" /d "%BROWSER_NAME%HTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".html" /d "%BROWSER_NAME%HTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".pdf" /d "%BROWSER_NAME%HTML" /f

:: Liên kết giao thức
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\URLAssociations" /v "http" /d "%BROWSER_NAME%URL" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\URLAssociations" /v "https" /d "%BROWSER_NAME%URL" /f

:: Đăng ký với RegisteredApplications
reg add "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /d "Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /f

echo.
echo [THANH CONG] Samsung Internet da duoc dang ky voi Windows!
echo.
echo CHU Y: Tren Windows 10/11, ban phai chon thu cong trong Settings:
echo 1. Cua so Default Apps se mo ngay sau day.
echo 2. Tim muc 'Web browser'.
echo 3. Chon '%BROWSER_NAME%' tu danh sach.
echo.

:: Mở cài đặt Default Apps
start "" "ms-settings:defaultapps"

pause
