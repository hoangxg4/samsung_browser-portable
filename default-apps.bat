@echo off

:: ==============================================
:: Samsung Browser Portable - Set Default Browser
:: Đặt Samsung Browser làm trình duyệt mặc định
:: ==============================================

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "CHROME_BIN=%SCRIPT_DIR%\Chrome-bin"
set "DATA_DIR=%SCRIPT_DIR%\Data"
set "BROWSER_NAME=Samsung Internet"

:: Check admin
NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process -FilePath '%~dpnx0' -Verb RunAs"
    EXIT /B
)

echo ================================================
echo   Samsung Browser - Set Default Browser
echo ================================================
echo.

:: Find exe
set "MAIN_EXE="
for /r "%CHROME_BIN%" %%f in (samsunginternet.exe) do (
    set "MAIN_EXE=%%f"
    goto :found_exe
)

:found_exe
if not defined MAIN_EXE (
    echo [ERROR] Samsung Browser chua duoc cai dat!
    pause
    exit /b 1
)

echo [INFO] File exe: %MAIN_EXE%
echo.

:: Clean up
reg delete "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%" /f >nul 2>&1
reg delete "HKLM\Software\Classes\samsunginternetHTML" /f >nul 2>&1
reg delete "HKLM\Software\Classes\samsunginternetURL" /f >nul 2>&1

:: Register browser
echo Dang dang ky trinh duyet...

reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%" /ve /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\DefaultIcon" /ve /d "\"%MAIN_EXE%\"" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\shell\open\command" /ve /d "\"%MAIN_EXE%\" --user-data-dir=\"%DATA_DIR%\" --no-first-run --no-default-browser-check \"%%1\"" /f

:: File associations
reg add "HKLM\Software\Classes\samsunginternetHTML" /ve /d "%BROWSER_NAME% Document" /f
reg add "HKLM\Software\Classes\samsunginternetHTML\shell\open\command" /ve /d "\"%MAIN_EXE%\" --user-data-dir=\"%DATA_DIR%\" \"%%1\"" /f

:: URL protocol
reg add "HKLM\Software\Classes\samsunginternetURL" /ve /d "%BROWSER_NAME% URL" /f
reg add "HKLM\Software\Classes\samsunginternetURL" /v "URL Protocol" /d "" /f
reg add "HKLM\Software\Classes\samsunginternetURL\shell\open\command" /ve /d "\"%MAIN_EXE%\" --user-data-dir=\"%DATA_DIR%\" \"%%1\"" /f

:: Capabilities
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /v "ApplicationName" /d "%BROWSER_NAME%" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /v "ApplicationDescription" /d "Samsung Internet Portable" /f

reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".htm" /d "samsunginternetHTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".html" /d "samsunginternetHTML" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\FileAssociations" /v ".pdf" /d "samsunginternetHTML" /f

reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\URLAssociations" /v "http" /d "samsunginternetURL" /f
reg add "HKLM\Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities\URLAssociations" /v "https" /d "samsunginternetURL" /f

reg add "HKLM\Software\RegisteredApplications" /v "%BROWSER_NAME%" /d "Software\Clients\StartMenuInternet\%BROWSER_NAME%\Capabilities" /f

:: Set as default
echo.
echo ================================================
echo   Dang ky hoan tat!
echo ================================================
echo.
echo Samsung Browser da duoc dang ky voi Windows.
echo.
echo Vui long mo Windows Settings > Default Apps de dat lam trinh duyet mac dinh!
echo Hoac bam Y de mo cua so cau hinh...
echo.

choice /c YN /m "Mo cau hinh Windows?"
if errorlevel 1 start "" "ms-settings:defaultapps"

pause
