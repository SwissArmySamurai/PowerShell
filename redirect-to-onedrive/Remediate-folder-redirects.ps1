# Ensure this runs in user context
$regPath = "HKCU:\Software\Policies\Microsoft\OneDrive"
New-Item -Path $regPath -Force | Out-Null

# Configure OneDrive KFM silent redirection
Set-ItemProperty -Path $regPath -Name "KFMSilentOptIn" -Value "$env:USERDOMAIN\$env:USERNAME" -Type String
Set-ItemProperty -Path $regPath -Name "KFMSilentOptInWithNotification" -Value 1 -Type DWord
Set-ItemProperty -Path $regPath -Name "KFMBlockOptOut" -Value 1 -Type DWord
Set-ItemProperty -Path $regPath -Name "SilentAccountConfig" -Value 1 -Type DWord

# Restart OneDrive client to enforce policy
$oneDriveExe = "$env:LOCALAPPDATA\Microsoft\OneDrive\OneDrive.exe"
if (Test-Path $oneDriveExe) {
    Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
    Start-Process -FilePath $oneDriveExe -NoNewWindow
}

Write-Output "✅ KFM policies applied and OneDrive restarted for redirection."
exit 0
