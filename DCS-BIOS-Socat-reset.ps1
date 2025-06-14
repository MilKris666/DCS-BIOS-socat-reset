# === Configuration ===
$logFile = "$env:USERPROFILE\Saved Games\DCS\Logs\dcs.log"
$connectCmd = "$env:USERPROFILE\Saved Games\DCS\Scripts\Programs\multiple-com-ports.cmd.lnk"
$pollInterval = 1  # Seconds

Write-Host "🔍 Waiting for Dispatcher (Main): Start..."

# === Live Log Monitoring ===
Get-Content -Path $logFile -Encoding UTF8 -Wait -Tail 100 | ForEach-Object {
    $line = $_

    if ($line -match "Dispatcher \(Main\): loadMission Done: Control passed to the Player") {
        Write-Host "`n✅ Mission start detected!"

        Write-Host "🛑 Stopping socat.exe..."
        Get-Process socat -ErrorAction SilentlyContinue | Stop-Process -Force

        Start-Sleep -Seconds 10

        Write-Host "🔁 Restarting connect-serial-port.cmd..."
        Start-Process -FilePath $connectCmd

        Write-Host "`n⏳ Waiting for next mission start..."
    }
    elseif ($line -match "Dispatcher \(Main\): Stop") {
        Write-Host "`n🛑 Mission end detected – stopping socat.exe..."
        Get-Process socat -ErrorAction SilentlyContinue | Stop-Process -Force
    }
}
