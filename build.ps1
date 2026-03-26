# ==============================================
# Samsung Browser Portable - Build Script
# Tải và cài đặt Samsung Browser Offline
# ==============================================

$ErrorActionPreference = "Stop"

# Đường dẫn
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ChromeBinDir = Join-Path $ScriptDir "Chrome-bin"
$DataDir = Join-Path $ScriptDir "Data"
$CacheDir = Join-Path $ScriptDir "Cache"
$WidevineDir = Join-Path $ScriptDir "WidevineCdm"
$TempDir = Join-Path $ScriptDir "temp"

# Màu sắc
function Write-ColorOutput($Message, $Color = "White") {
    $colors = @{
        "Red" = [ConsoleColor]::Red
        "Green" = [ConsoleColor]::Green
        "Yellow" = [ConsoleColor]::Yellow
        "Cyan" = [ConsoleColor]::Cyan
        "White" = [ConsoleColor]::White
    }
    Write-Host $Message -ForegroundColor $colors[$Color]
}

Write-ColorOutput "================================================" "Cyan"
Write-ColorOutput "  Samsung Browser Portable - Build Script" "Cyan"
Write-ColorOutput "================================================" "Cyan"
Write-Host ""

# Kiểm tra phiên bản hiện tại
$CurrentVersion = ""
$VersionFile = Join-Path $ScriptDir "version.txt"
if (Test-Path $VersionFile) {
    $CurrentVersion = Get-Content $VersionFile -Raw.Trim()
    Write-ColorOutput "[INFO] Phien ban hien tai: $CurrentVersion" "Yellow"
} else {
    Write-ColorOutput "[INFO] Chua co phien ban nao duoc cai dat" "Yellow"
}

# Tạo thư mục tạm
if (-not (Test-Path $TempDir)) {
    New-Item -ItemType Directory -Path $TempDir | Out-Null
}

Write-Host ""
Write-ColorOutput "[1/5] Dang kiem tra phien ban moi nhat..." "Cyan"

# Lấy thông tin phiên bản mới nhất từ GitHub
try {
    $ReleaseInfo = Invoke-RestMethod -Uri "https://api.github.com/repos/hoangxg4/samsung_browser-offline-installer/releases/latest" -UserAgent "SamsungBrowser"
    $DownloadUrl = $ReleaseInfo.assets | Where-Object { $_.name -match "SamsungInternet_Offline" } | Select-Object -First 1 | ForEach-Object { $_.browser_download_url }
    
    if ($DownloadUrl -match "v([\d\.]+)") {
        $NewVersion = $matches[1]
    } else {
        $NewVersion = "143.0.0.95"
    }
} catch {
    Write-ColorOutput "[WARNING] Khong the kiem tra phien ban tu GitHub, su dung mac dinh..." "Yellow"
    $NewVersion = "143.0.0.95"
    $DownloadUrl = "https://github.com/hoangxg4/samsung_browser-offline-installer/releases/download/v$NewVersion/SamsungInternet_Offline_v$NewVersion.zip"
}

Write-ColorOutput "[INFO] Phien ban moi nhat: $NewVersion" "Green"

# So sánh phiên bản
if ($CurrentVersion -eq $NewVersion) {
    Write-Host ""
    Write-ColorOutput "[INFO] Phien ban hien tai la moi nhat!" "Green"
    
    if (Test-Path $ChromeBinDir) {
        Write-ColorOutput "[INFO] Thu muc Chrome-bin da ton tai" "Yellow"
        goto :CheckExisting
    }
}

Write-Host ""
Write-ColorOutput "[2/5] Dang tai Samsung Browser v$NewVersion..." "Cyan"

# Tải file
$ZipFile = Join-Path $TempDir "SamsungInternet_Offline_v$NewVersion.zip"
Write-ColorOutput "[INFO] Link tai: $DownloadUrl" "White"

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipFile -UserAgent "SamsungBrowser" -UseBasicParsing
} catch {
    Write-ColorOutput "[ERROR] Loi khi tai file: $_" "Red"
    exit 1
}

Write-ColorOutput "[OK] Tai hoan tat!" "Green"

Write-Host ""
Write-ColorOutput "[3/5] Dang giai nen..." "Cyan"

# Giải nén zip đầu tiên (chứa mini_installer.exe)
$ExtractDir = Join-Path $TempDir "installer"
if (Test-Path $ExtractDir) {
    Remove-Item $ExtractDir -Recurse -Force
}
New-Item -ItemType Directory -Path $ExtractDir | Out-Null

Expand-Archive -Path $ZipFile -DestinationPath $ExtractDir -Force

# Tìm mini_installer.exe
$MiniInstaller = Get-ChildItem -Path $ExtractDir -Filter "mini_installer.exe" -Recurse | Select-Object -First 1

if (-not $MiniInstaller) {
    Write-ColorOutput "[ERROR] Khong tim thay mini_installer.exe" "Red"
    exit 1
}

Write-ColorOutput "[OK] Tim thay: $($MiniInstaller.Name)" "Green"

# Giải nén mini_installer.exe (chứa samsunginternet.7z)
Write-ColorOutput "[INFO] Dang giai nen mini_installer.exe..." "Cyan"
$SevenZipFile = Join-Path $TempDir "samsunginternet.7z"

# Chạy silent extraction
$Process = Start-Process -FilePath $MiniInstaller.FullName -ArgumentList "/s /d`"$TempDir`"" -Wait -PassThru -WindowStyle Hidden
Start-Sleep -Seconds 3

# Tìm file 7z
$SevenZipFile = Get-ChildItem -Path $TempDir -Filter "samsunginternet.7z" | Select-Object -First 1

if (-not $SevenZipFile) {
    # Thử cách khác - giải nén từ thư mục temp của installer
    $SevenZipFile = Get-ChildItem -Path $env:TEMP -Filter "samsunginternet.7z" -Recurse | Select-Object -First 1
    
    if ($SevenZipFile) {
        $Target7z = Join-Path $TempDir "samsunginternet.7z"
        Copy-Item $SevenZipFile.FullName $Target7z -Force
        $SevenZipFile = Get-Item $Target7z
    }
}

if (-not $SevenZipFile) {
    Write-ColorOutput "[ERROR] Khong tim thay samsunginternet.7z" "Red"
    Write-ColorOutput "[INFO] Thu giai nen thu cong bang cach khac..." "Yellow"
    
    # Thử sử dụng 7-Zip nếu có
    $SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
    if (-not (Test-Path $SevenZipPath)) {
        $SevenZipPath = "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
    }
    
    if (Test-Path $SevenZipPath) {
        & $SevenZipPath x $MiniInstaller.FullName "-o$TempDir" -y | Out-Null
        $SevenZipFile = Get-ChildItem -Path $TempDir -Filter "samsunginternet.7z" | Select-Object -First 1
    }
}

if ($SevenZipFile) {
    Write-ColorOutput "[OK] Tim thay samsunginternet.7z" "Green"
    
    # Giải nén 7z
    Write-ColorOutput "[INFO] Dang giai nen samsunginternet.7z..." "Cyan"
    
    # Sử dụng PowerShell Expand-Archive nếu là zip, hoặc 7z
    if ($SevenZipFile.Extension -eq ".zip") {
        Expand-Archive -Path $SevenZipFile.FullName -DestinationPath $ChromeBinDir -Force
    } else {
        # Dùng 7-Zip
        $SevenZipPath = "C:\Program Files\7-Zip\7z.exe"
        if (-not (Test-Path $SevenZipPath)) {
            $SevenZipPath = "${env:ProgramFiles(x86)}\7-Zip\7z.exe"
        }
        
        if (Test-Path $SevenZipPath) {
            & $SevenZipPath x $SevenZipFile.FullName "-o$ChromeBinDir" -y | Out-Null
        } else {
            Write-ColorOutput "[ERROR] Can cai dat 7-Zip de giai nen file .7z" "Red"
            Write-ColorOutput "[INFO] Tai file: https://www.7-zip.org/" "White"
            exit 1
        }
    }
    
    Write-ColorOutput "[OK] Giai nen hoan tat!" "Green"
}

# Kiểm tra Chrome-bin
:CheckExisting
if (-not (Test-Path $ChromeBinDir)) {
    Write-ColorOutput "[ERROR] Khong tim thay thu muc Chrome-bin" "Red"
    exit 1
}

# Tìm executable chính
$ExeFiles = Get-ChildItem -Path $ChromeBinDir -Filter "*.exe" -Recurse | Where-Object { $_.Name -match "samsunginternet|chrome" }
$MainExe = $ExeFiles | Where-Object { $_.Name -notmatch "setup|uninstall|helper" } | Select-Object -First 1

if (-not $MainExe) {
    Write-ColorOutput "[ERROR] Khong tim thay file exe chinh" "Red"
    exit 1
}

Write-ColorOutput "[OK] Tim thay: $($MainExe.Name)" "Green"

Write-Host ""
Write-ColorOutput "[4/5] Cai dat Widevine..." "Cyan"

# Cài đặt Widevine
if (Test-Path $WidevineDir) {
    # Copy Widevine vào thư mục Chrome
    $WidevineDest = Join-Path $MainExe.DirectoryName "WidevineCdm"
    
    if (-not (Test-Path $WidevineDest)) {
        Copy-Item -Path $WidevineDir -Destination $WidevineDest -Recurse -Force
    }
    
    Write-ColorOutput "[OK] Da cai dat Widevine" "Green"
} else {
    Write-ColorOutput "[WARNING] Thu muc WidevineCdm khong ton tai" "Yellow"
}

Write-Host ""
Write-ColorOutput "[5/5] Hoan tat cau hinh..." "Cyan"

# Tạo thư mục Data và Cache
if (-not (Test-Path $DataDir)) {
    New-Item -ItemType Directory -Path $DataDir | Out-Null
}
if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir | Out-Null
}

# Lưu phiên bản
$NewVersion | Out-File -FilePath $VersionFile -Encoding UTF8

# Dọn dẹp
if (Test-Path $ZipFile) { Remove-Item $ZipFile -Force }
if (Test-Path $ExtractDir) { Remove-Item $ExtractDir -Recurse -Force }

Write-Host ""
Write-ColorOutput "================================================" "Green"
Write-ColorOutput "  Cai dat hoan tat!" "Green"
Write-ColorOutput "================================================" "Green"
Write-Host ""
Write-ColorOutput "Phien ban: $NewVersion" "White"
Write-ColorOutput "File exe: $($MainExe.FullName)" "White"
Write-ColorOutput "Thu muc Data: $DataDir" "White"
Write-Host ""
Write-ColorOutput "Ban co the chay SamsungBrowser.exe de khoi dong!" "Green"
Write-Host ""

# Tạo shortcut
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut(Join-Path $ScriptDir "SamsungBrowser.lnk")
$Shortcut.TargetPath = $MainExe.FullName
$Shortcut.Arguments = "--user-data-dir=`"$DataDir`" --disk-cache-dir=`"$CacheDir`" --no-first-run --no-default-browser-check"
$Shortcut.WorkingDirectory = $ScriptDir
$Shortcut.Description = "Samsung Browser Portable"
$Shortcut.Save()

Write-ColorOutput "[OK] Da tao shortcut SamsungBrowser.lnk" "Green"

pause
