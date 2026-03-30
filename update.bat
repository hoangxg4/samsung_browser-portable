@echo off
setlocal
echo Samsung Browser Portable Auto-Updater
echo =====================================
echo.

set "PS_FILE=%TEMP%\samsung_autoupdate.ps1"
(
echo $ErrorActionPreference = "Stop"
echo $currentDir = "%~dp0"
echo $browserExe = Join-Path $currentDir "samsunginternet.exe"
echo $apiUrl = "https://api.github.com/repos/hoangxg4/samsung_browser-portable/releases/latest"
echo $tempDir = Join-Path $env:TEMP "SamsungBrowserUpdate"
echo.
echo try {
echo    # 1. Kiem tra phien ban hien tai
echo    $currentVersion = "0.0.0.0"
echo    if ^(Test-Path $browserExe^) { $currentVersion = ^(Get-Item $browserExe^).VersionInfo.ProductVersion }
echo.
echo    Write-Host "Checking for updates..." -ForegroundColor Cyan
echo    $release = Invoke-RestMethod -Uri $apiUrl
echo    $latestVersion = $release.tag_name.Trim^('v'^)
echo    $downloadUrl = $release.assets ^| Where-Object { $_.name -like "*.zip" } ^| Select-Object -ExpandProperty browser_download_url -First 1
echo.
echo    Write-Host "Current version: $currentVersion"
echo    Write-Host "Latest version:  $latestVersion"
echo.
echo    # 2. So sanh phien ban
echo    if ^($currentVersion -eq $latestVersion^) {
echo        Write-Host "You are already using the latest version!" -ForegroundColor Green
echo        Start-Sleep -Seconds 3
echo        exit 0
echo    }
echo.
echo    # 3. Tu dong cap nhat neu co ban moi
echo    Write-Host "New version found! Starting auto-update in 3 seconds..." -ForegroundColor Yellow
echo    Start-Sleep -Seconds 3
echo.
echo    Write-Host "Closing Browser..." -ForegroundColor Cyan
echo    Stop-Process -Name "samsunginternet" -Force -ErrorAction SilentlyContinue
echo    Start-Sleep -Seconds 2
echo.
echo    # 4. Tai file zip
echo    if ^(Test-Path $tempDir^) { Remove-Item $tempDir -Recurse -Force }
echo    New-Item -ItemType Directory -Path $tempDir -Force ^| Out-Null
echo    $zipFile = Join-Path $tempDir "update.zip"
echo.
echo    Write-Host "Downloading update..." -ForegroundColor Cyan
echo    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
echo.
echo    # 5. Giai nen
echo    Write-Host "Extracting files..." -ForegroundColor Cyan
echo    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
echo.
echo    # Tim thu muc goc
echo    $extractedSource = Get-ChildItem $tempDir -Recurse -Directory ^| Where-Object { $_.Name -eq "Samsung_Browser" } ^| Select-Object -First 1
echo    if ^(-not $extractedSource^) { 
echo        $extractedSource = Get-ChildItem $tempDir -Directory ^| Select-Object -First 1
echo    }
echo.
echo    # 6. Ghi de file (Bao ve du lieu nguoi dung)
echo    Write-Host "Applying update..." -ForegroundColor Cyan
echo    $protectedFiles = @^("chrome++.ini", "debloater.reg", "update.bat", "default-apps-multi-profile.bat", "Data", "Cache"^)
echo.
echo    Get-ChildItem $extractedSource.FullName -Recurse ^| ForEach-Object {
echo        $relativePath = $_.FullName.Substring^($extractedSource.FullName.Length + 1^)
echo        $destPath = Join-Path $currentDir $relativePath
echo.
echo        if ^($_.PSIsContainer^) {
echo            if ^(-not ^(Test-Path $destPath^)^) { New-Item -ItemType Directory -Path $destPath -Force ^| Out-Null }
echo        } else {
echo            $skip = $false
echo            foreach ^($protected in $protectedFiles^) {
echo                if ^($relativePath -eq $protected -or $relativePath -like "$protected\*"^) {
echo                    if ^(Test-Path $destPath^) { $skip = $true; break }
echo                }
echo            }
echo            if ^(-not $skip^) {
echo                $parentDir = Split-Path $destPath
echo                if ^(-not ^(Test-Path $parentDir^)^) { New-Item -ItemType Directory -Path $parentDir -Force ^| Out-Null }
echo                Copy-Item $_.FullName -Destination $destPath -Force
echo            }
echo        }
echo    }
echo.
echo    # 7. Don dep va Ket thuc
echo    Remove-Item $tempDir -Recurse -Force
echo    Write-Host "Update completed successfully!" -ForegroundColor Green
echo    Start-Sleep -Seconds 3
echo.
echo } catch {
echo    Write-Host "Error: $_" -ForegroundColor Red
echo    Start-Sleep -Seconds 5
echo }
) > "%PS_FILE%"

powershell -NoProfile -ExecutionPolicy Bypass -File "%PS_FILE%"
del "%PS_FILE%" 2>nul
