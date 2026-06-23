# DxMart Backend — Auto-restart server
# Usage: Right-click → Run with PowerShell  (OR)  .\start_server.ps1

$restartCount = 0

Write-Host "=== DxMart Backend Server ===" -ForegroundColor Cyan
Write-Host "URL: http://0.0.0.0:8000" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop permanently." -ForegroundColor Gray
Write-Host ""

while ($true) {
    if ($restartCount -gt 0) {
        Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Restart #$restartCount..." -ForegroundColor Yellow
    }

    php artisan serve --host=0.0.0.0 --port=8000

    $restartCount++
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Server stopped. Restarting in 3s..." -ForegroundColor Red
    Start-Sleep -Seconds 3
}
