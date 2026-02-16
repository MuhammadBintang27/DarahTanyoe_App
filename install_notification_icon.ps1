# Auto Copy Notification Icon ke Project
# Jalankan setelah download ZIP dari Android Asset Studio

param(
    [string]$ZipPath = "$env:USERPROFILE\Downloads\ic_notification.zip"
)

Write-Host "=== Auto Install Notification Icons ===" -ForegroundColor Cyan
Write-Host ""

# Check if ZIP exists
if (-not (Test-Path $ZipPath)) {
    Write-Host "X ZIP file not found at: $ZipPath" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Go to: https://romannurik.github.io/AndroidAssetStudio/icons-notification.html" -ForegroundColor White
    Write-Host "2. Upload your logo (blood drop with cross)" -ForegroundColor White
    Write-Host "3. Set Name: ic_notification" -ForegroundColor White
    Write-Host "4. Download ZIP" -ForegroundColor White
    Write-Host "5. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "Or specify ZIP location:" -ForegroundColor Yellow
    Write-Host "  .\install_notification_icon.ps1 -ZipPath 'C:\path\to\ic_notification.zip'" -ForegroundColor Gray
    exit 1
}

Write-Host "OK Found ZIP: $ZipPath" -ForegroundColor Green
Write-Host ""

# Extract to temp folder
$tempFolder = "$env:TEMP\ic_notification_extract"
if (Test-Path $tempFolder) {
    Remove-Item $tempFolder -Recurse -Force
}
New-Item -ItemType Directory -Path $tempFolder | Out-Null

Write-Host "Extracting ZIP..." -ForegroundColor Yellow
try {
    Expand-Archive -Path $ZipPath -DestinationPath $tempFolder -Force
    Write-Host "OK Extracted" -ForegroundColor Green
} catch {
    Write-Host "X Failed to extract: $_" -ForegroundColor Red
    exit 1
}

# Find res folder
$resFolder = Get-ChildItem -Path $tempFolder -Recurse -Directory -Filter "res" | Select-Object -First 1

if (-not $resFolder) {
    Write-Host "X 'res' folder not found in ZIP" -ForegroundColor Red
    exit 1
}

Write-Host "OK Found res folder: $($resFolder.FullName)" -ForegroundColor Green
Write-Host ""

# Copy to project
$projectResPath = "d:\Skripsi\CODE\DarahTanyoe_App\android\app\src\main\res"

Write-Host "Copying notification icons to project..." -ForegroundColor Yellow

$densities = @("drawable-anydpi-v24", "drawable-hdpi", "drawable-mdpi", "drawable-xhdpi", "drawable-xxhdpi", "drawable-xxxhdpi")
$copiedCount = 0

foreach ($density in $densities) {
    $sourcePath = Join-Path $resFolder.FullName $density
    $destPath = Join-Path $projectResPath $density
    
    if (Test-Path $sourcePath) {
        # Create destination if not exists
        if (-not (Test-Path $destPath)) {
            New-Item -ItemType Directory -Path $destPath -Force | Out-Null
        }
        
        # Copy ic_notification files
        $files = Get-ChildItem -Path $sourcePath -Filter "ic_notification*"
        foreach ($file in $files) {
            Copy-Item $file.FullName -Destination $destPath -Force
            Write-Host "  OK Copied: $density/$($file.Name)" -ForegroundColor Green
            $copiedCount++
        }
    }
}

Write-Host ""
if ($copiedCount -gt 0) {
    Write-Host "SUCCESS! Copied $copiedCount icon files" -ForegroundColor Green
    Write-Host ""
    Write-Host "Notification icons are now installed!" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Yellow
    Write-Host "1. Rebuild app: flutter clean && flutter run" -ForegroundColor White
    Write-Host "2. Test notification" -ForegroundColor White
    Write-Host "3. Check status bar for custom icon" -ForegroundColor White
} else {
    Write-Host "X No icon files were copied" -ForegroundColor Red
}

# Cleanup
Remove-Item $tempFolder -Recurse -Force
Write-Host ""
Write-Host "Done!" -ForegroundColor Cyan
