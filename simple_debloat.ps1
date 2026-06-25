# Quick Windows 11 Debloat Script - Removes specified Appx packages

# List of packages to remove
$BloatApps = @(
  'Microsoft.Bing*',                  # BingNews, BingWeather, BingFinance etc.
  'Microsoft.GetHelp',
  'Microsoft.Getstarted',             # Tips
  'Microsoft.MicrosoftOfficeHub',     # Office promo
  'Microsoft.MicrosoftSolitaireCollection',
  'Microsoft.MicrosoftStickyNotes',   # comment out if you use it
  'Microsoft.Microsoft3DViewer',
  'Microsoft.MSPaint*Preview*',
  'Microsoft.MicrosoftNews',
  'Microsoft.MixedReality.Portal',
  'Microsoft.OneConnect',             # Mobile plans
  'Microsoft.People',
  'Microsoft.PowerAutomateDesktop',   # comment out if you want to keep it
  'Microsoft.SkypeApp',
  'Microsoft.Todos',
  'Microsoft.Wallet',
  'Microsoft.WindowsAlarms',
  'Microsoft.WindowsMaps',
  'Microsoft.WindowsFeedbackHub',
  'Microsoft.WindowsSoundRecorder',
  'Microsoft.YourPhone*',             # Phone Link
  'Microsoft.ZuneMusic',              # Groove Music (legacy)
  'Microsoft.ZuneVideo',
  'Microsoft.GamingApp',              # Xbox App
  'Microsoft.Xbox*',                  # All Xbox packages
  'MicrosoftWindows.Client.WebExperience' # Widgets
)

Write-Host "Starting Appx removal..." -ForegroundColor Cyan

foreach ($app in $BloatApps) {
    # Remove for current/all users
    Get-AppxPackage -AllUsers -Name $app -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "Removing installed package $($_.Name)" -ForegroundColor Yellow
        Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
    }

    # Remove from provisioned image (so it doesn't come back for new users)
    Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app } | ForEach-Object {
        Write-Host "Removing provisioned package $($_.DisplayName)" -ForegroundColor Red
        Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
    }
}
Write-Host "Appx removal complete." -ForegroundColor Green
