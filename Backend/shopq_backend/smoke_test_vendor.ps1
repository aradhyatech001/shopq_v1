$token = '3|gUMGcLNEKoKSePsRJqGaHLpl6P1dEfxd7kIHyzqk384aaf16'
$base = 'http://192.168.1.5:8000'
$urls = @(
    '/api/vendor/profile',
    '/api/vendor/products',
    '/api/vendor/orders',
    '/api/vendor/pincodes',
    '/api/vendor/pincodes/update'
)

foreach ($u in $urls) {
    $method = 'GET'
    if ($u -like '*update*') { $method = 'POST' }
    $body = $null
    if ($u -eq '/api/vendor/pincodes/update') { $body = @{ pincodes = @(560001) } | ConvertTo-Json }
    try {
        if ($body) {
            $resp = Invoke-RestMethod -Uri "$base$u" -Method $method -Headers @{ Authorization = "Bearer $token" } -Body $body -ContentType 'application/json' -ErrorAction Stop
        } else {
            $resp = Invoke-RestMethod -Uri "$base$u" -Method $method -Headers @{ Authorization = "Bearer $token" } -ErrorAction Stop
        }
        Write-Output "OK $u : $(ConvertTo-Json $resp -Depth 3)"
    } catch {
        Write-Output "ERR $u : $($_.Exception.Message)"
    }
    Start-Sleep -Milliseconds 300
}
