# List of unwanted auto-installed apps
$unwantedApps = @(
    "Microsoft.XboxGamingOverlay",
    "Microsoft.Xbox.TCUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxApp",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.SkypeApp",
    "Microsoft.TikTok",
    "SpotifyAB.SpotifyMusic",
    "Disney.37853FC22B2CE",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.BingNews",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp"
    "Microsoft.Messaging"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.NetworkSpeedTest"
    "Microsoft.News"
    "Microsoft.Office.Lens"
    "Microsoft.Office.OneNote"
    "Microsoft.Office.Sway"
    "Microsoft.OneConnect"
    "Microsoft.People"
    "Microsoft.Print3D"
    "Microsoft.RemoteDesktop"
    "Microsoft.SkypeApp"
    "Microsoft.StorePurchaseApp"
    "Microsoft.Office.Todo.List"
    "Microsoft.Whiteboard"
    "Microsoft.WindowsAlarms"
    "Microsoft.MicrosoftStickyNotes"
    "MicrosoftCorporationII.QuickAssist"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.GamingApp"
    "Microsoft.GamingServices"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.XboxDevices"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
    "Clipchamp.Clipchamp_yxz26nhyzhsrt"
    "Clipchamp.Clipchamp"
    "Microsoft.YourPhone"
    "Microsoft.MSPaint"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Todos"
    "Microsoft.PowerAutomateDesktop"
    "Microsoft.MicrosoftJournal"
    "Microsoft.BingTranslator"
    "Microsoft.BingWeather"
    "Microsoft.WindowsStore"
    "Microsoft.549981C3F5F10"
)

# Get installed apps
$installedApps = Get-AppxPackage | Select-Object -ExpandProperty Name

# Check for unwanted apps
$foundApps = $unwantedApps | Where-Object { $_ -in $installedApps }

# Output detection
if ($foundApps.Count -gt 0) {
    Write-Host "Detected unwanted apps: $($foundApps -join ', ')"
    exit 1  # Trigger remediation
} else {
    Write-Host "No unwanted apps found"
    exit 0
}
