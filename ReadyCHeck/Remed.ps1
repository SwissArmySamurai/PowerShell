# Make sure system has PC Health Check and prerequisites
$healthCheckUrl = "https://aka.ms/GetPCHealthCheckApp"
$pcHealthPath = "$env:ProgramFiles\PCHealthCheck\HealthCheck.exe"

if (-not (Test-Path $pcHealthPath)) {
    $tempFile = "$env:TEMP\PCHealth.msi"
    Invoke-WebRequest -Uri $healthCheckUrl -OutFile $tempFile
    Start-Process msiexec.exe -ArgumentList "/i `"$tempFile`" /quiet /norestart" -Wait
    Remove-Item $tempFile
}

# Enable TPM, Secure Boot, and UEFI (warning: cannot fully automate all of these safely via script)
# Optional: Notify user or open BIOS guidance

# Trigger Windows Update readiness refresh
$null = Get-WindowsUpdateLog
Start-ScheduledTask -TaskName "Microsoft Compatibility Appraiser"

# Optional: Register readiness logs
Write-EventLog -LogName "Application" -Source "Windows Update" -EntryType Information -EventId 1 -Message "Triggered Compatibility Appraiser"

Start-Sleep -Seconds 30
