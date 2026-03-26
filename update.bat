@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

echo ================================================
echo   Samsung Browser - Cap nhat
echo ================================================
echo.

:: Lay phien ban moi
for /f "delims=" %%i in ('powershell -Command "(Invoke-RestMethod -Uri 'https://api.github.com/repos/hoangxg4/samsung_browser-portable/releases/latest' -UserAgent 'Samsung').name -replace 'Samsung Browser v',''"') do set "NEW_VER=%%i"

echo Phien ban moi: %NEW_VER%

:: Kiem tra da cai chua
if not exist "%SCRIPT_DIR%\version.txt" (
    echo Ban can tai file zip tu Release de cai dat lan dau!
    start https://github.com/hoangxg4/samsung_browser-portable/releases
    pause
    exit /b 1
)

set /p CUR_VER=<"%SCRIPT_DIR%\version.txt"
echo Phien ban hien tai: %CUR_VER%

if "%CUR_VER%"=="%NEW_VER%" (
    echo.
    echo Ban dang su dung phien ban moi nhat!
    pause
    exit /b 0
)

echo.
echo Phien ban moi: %NEW_VER%
echo Hay tai file SamsungBrowser-%NEW_VER%.zip tu:
echo https://github.com/hoangxg4/samsung_browser-portable/releases
echo.
echo Sau khi tai ve, giai nen va copy noi dung thu muc SamsungBrowser
echo vao thu muc hien tai (ghi de cac file cu).
echo.
pause
