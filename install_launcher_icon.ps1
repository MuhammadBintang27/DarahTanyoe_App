# Script untuk menginstall Launcher Icon dari Android Asset Studio
# Generated: 2026-02-16

param(
    [string]$ZipPath
)

Write-Host "=== Installing Launcher Icon ===" -ForegroundColor Cyan
Write-Host ""

# Jika tidak ada ZIP path, cari di Downloads
if ([string]::IsNullOrEmpty($ZipPath)) {
    $downloadsPath = [Environment]::GetFolderPath("UserProfile") + "\Downloads"
    Write-Host "Mencari ZIP di: $downloadsPath" -ForegroundColor Yellow
    
    # Cari file ZIP terbaru yang mengandung "ic_launcher"
    $zipFiles = Get-ChildItem -Path $downloadsPath -Filter "*.zip" | 
                Where-Object { $_.Name -like "*ic_launcher*" -or $_.Name -like "*launcher*" } |
                Sort-Object LastWriteTime -Descending
    
    if ($zipFiles.Count -eq 0) {
        Write-Host "Tidak ditemukan ZIP launcher icon di Downloads!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Cara manual:" -ForegroundColor Yellow
        Write-Host "  .\install_launcher_icon.ps1 -ZipPath 'C:\path\to\your\launcher-icon.zip'"
        exit 1
    }
    
    $ZipPath = $zipFiles[0].FullName
    Write-Host "Ditemukan: $($zipFiles[0].Name)" -ForegroundColor Green
}

# Validasi file ZIP
if (-not (Test-Path $ZipPath)) {
    Write-Host "File tidak ditemukan: $ZipPath" -ForegroundColor Red
    exit 1
}

Write-Host "Menggunakan ZIP: $ZipPath" -ForegroundColor Cyan
Write-Host ""

# Buat folder temporary
$tempDir = Join-Path $env:TEMP "launcher_icon_extract"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

# Extract ZIP
Write-Host "Extracting ZIP..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $ZipPath -DestinationPath $tempDir -Force
    Write-Host "Extract berhasil" -ForegroundColor Green
} catch {
    Write-Host "Gagal extract ZIP: $_" -ForegroundColor Red
    exit 1
}

# Cari folder res/ di dalam extract
$resFolder = Get-ChildItem -Path $tempDir -Filter "res" -Recurse -Directory | Select-Object -First 1

if (-not $resFolder) {
    Write-Host "Folder 'res' tidak ditemukan di dalam ZIP!" -ForegroundColor Red
    Write-Host "Struktur ZIP:" -ForegroundColor Yellow
    Get-ChildItem -Path $tempDir -Recurse | Select-Object FullName
    exit 1
}

Write-Host "Ditemukan folder res: $($resFolder.FullName)" -ForegroundColor Green
Write-Host ""

# Target folder di project
$projectResFolder = "d:\Skripsi\CODE\DarahTanyoe_App\android\app\src\main\res"

if (-not (Test-Path $projectResFolder)) {
    Write-Host "Folder project tidak ditemukan: $projectResFolder" -ForegroundColor Red
    exit 1
}

# Folder-folder yang perlu di-copy untuk launcher icon
$mipmapFolders = @(
    "mipmap-hdpi",
    "mipmap-mdpi",
    "mipmap-xhdpi",
    "mipmap-xxhdpi",
    "mipmap-xxxhdpi",
    "mipmap-anydpi-v26"
)

Write-Host "Copying launcher icon files..." -ForegroundColor Yellow
$copiedCount = 0

foreach ($folder in $mipmapFolders) {
    $sourceFolder = Join-Path $resFolder.FullName $folder
    $targetFolder = Join-Path $projectResFolder $folder
    
    if (Test-Path $sourceFolder) {
        # Buat folder target jika belum ada
        if (-not (Test-Path $targetFolder)) {
            New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
        }
        
        # Copy semua file dari source ke target
        $files = Get-ChildItem -Path $sourceFolder -File
        foreach ($file in $files) {
            $targetFile = Join-Path $targetFolder $file.Name
            Copy-Item -Path $file.FullName -Destination $targetFile -Force
            Write-Host "  Copied: $folder/$($file.Name)" -ForegroundColor Green
            $copiedCount++
        }
    } else {
        Write-Host "  Skipped: $folder (tidak ada di ZIP)" -ForegroundColor DarkGray
    }
}

Write-Host ""

if ($copiedCount -eq 0) {
    Write-Host "Tidak ada file yang berhasil di-copy!" -ForegroundColor Red
    exit 1
}

Write-Host "Berhasil copy $copiedCount file!" -ForegroundColor Green
Write-Host ""

# Cleanup
Remove-Item $tempDir -Recurse -Force

# Instruksi selanjutnya
Write-Host "=== Next Steps ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Rebuild aplikasi:" -ForegroundColor Yellow
Write-Host "   flutter clean" -ForegroundColor White
Write-Host "   flutter run" -ForegroundColor White
Write-Host ""
Write-Host "2. Cek launcher icon di home screen HP" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: Launcher icon mungkin perlu waktu untuk refresh" -ForegroundColor Gray
Write-Host "      di home screen. Jika belum muncul, coba restart HP." -ForegroundColor Gray
Write-Host ""
Write-Host "Done!" -ForegroundColor Green
