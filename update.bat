@echo off
setlocal
echo Samsung Browser Portable Updater v1.1
echo =======================================
echo.
(
echo # Samsung Browser Updater Script
echo $ErrorActionPreference = "Stop"
echo $browserExe = Join-Path "%~dp0" "samsunginternet.exe"
echo $apiUrl = "https://api.github.com/repos/hoangxg4/samsung_browser-portable/releases/latest"
echo $tempDir = Join-Path $env:TEMP "SamsungBrowserUpdate"
echo.
echo try {
echo    # 1. Kiem tra phien ban hien tai
echo    $currentVersion = if (Test-Path $browserExe) { (Get-Item $browserExe).VersionInfo.ProductVersion } else { "0.0.0.0" }
echo.
echo    # 2. Lay thong tin tu GitHub API
echo    $latestRelease = Invoke-RestMethod -Uri $apiUrl
echo    $latestVersion = $latestRelease.tag_name -replace 'v',''
echo    $downloadUrl = $latestRelease.assets | Where-Object { $_.name -like "*.zip" } | Select-Object -ExpandProperty browser_download_url -First 1
echo.
echo    Write-Host "Current version: $currentVersion" -ForegroundColor Yellow
echo    Write-Host "Latest version:  $latestVersion" -ForegroundColor Yellow
echo    Write-Host ""
echo.
echo    if ($currentVersion -eq $latestVersion) {
echo        Write-Host "You are already using the latest version." -ForegroundColor Green
echo        $confirm = Read-Host "Do you want to re-install? (y/N)"
echo    } else {
echo        $confirm = Read-Host "New version available! Do you want to update? (y/N)"
echo    }
echo.
echo    if ($confirm -ne 'y' -and $confirm -ne 'Y') { exit }
echo.
echo    # 3. Dung tien trinh dang chay
echo    Write-Host "Closing Browser..." -ForegroundColor Cyan
echo    Stop-Process -Name "samsunginternet" -Force -ErrorAction SilentlyContinue
echo    Start-Sleep -Seconds 2
echo.
echo    # 4. Tai file ve thu muc tam
echo    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force }
echo    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
echo    $zipFile = Join-Path $tempDir "update.zip"
echo.
echo    Write-Host "Downloading update..." -ForegroundColor Cyan
echo    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipFile
echo.
echo    # 5. Giai nen
echo    Write-Host "Extracting files..." -ForegroundColor Cyan
echo    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
echo.
echo    # 6. Tim thu muc Samsung_Browser ben trong file zip
echo    $extractedSource = Get-ChildItem $tempDir -Recurse -Directory | Where-Object { $_.Name -eq "Samsung_Browser" } | Select-Object -First 1
echo    if (-not $extractedSource) { 
echo        # Neu khong thay thu muc Samsung_Browser thi lay thu muc con dau tien
echo        $extractedSource = Get-ChildItem $tempDir -Directory | Select-Object -First 1
echo    }
echo.
echo    $currentDir = "%~dp0"
echo.
echo    Write-Host "Updating files to $currentDir ..." -ForegroundColor Cyan
echo.
echo    # 7. Copy ghi de vao thu muc hien tai (loai tru file config)
echo    $protectedFiles = @("chrome++.ini", "debloater.reg", "update.bat", "Data", "Cache")
echo.
echo    Get-ChildItem $extractedSource.FullName -Recurse | ForEach-Object {
echo        $relativePath = $_.FullName.Substring($extractedSource.FullName.Length + 1)
echo        $destPath = Join-Path $currentDir $relativePath
echo.
echo        if ($_.PSIsContainer) {
echo            if (-not (Test-Path $destPath)) { New-Item -ItemType Directory -Path $destPath -Force | Out-Null }
echo        } else {
echo            if ($protectedFiles -contains $_.Name -and (Test-Path $destPath)) {
echo                Write-Host "Skipping protected: $($_.Name)" -ForegroundColor Gray
echo            } else {
echo                $parentDir = Split-Path $destPath
echo                if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
echo                Copy-Item $_.FullName -Destination $destPath -Force
echo            }
echo        }
echo    }
echo.
echo    # 8. Don dep
echo    Remove-Item $tempDir -Recurse -Force
echo    Write-Host ""
echo    Write-Host "Update completed successfully!" -ForegroundColor Green
echo.
echo } catch {
echo    Write-Host "Error: $_" -ForegroundColor Red
echo }
echo.
echo Read-Host "Press Enter to exit"
) > "%TEMP%\samsung_update.ps1"

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\samsung_update.ps1"
del "%TEMP%\samsung_update.ps1" 2>nul
