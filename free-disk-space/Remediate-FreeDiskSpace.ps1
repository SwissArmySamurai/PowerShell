# Dynamically detect the system drive (e.g., "C:")
$driveLetter = ([System.IO.DirectoryInfo]$env:SystemRoot).Root.Name.TrimEnd("\")  # e.g., "C:"

# Clean Temp folders for all user profiles
$usersPath = "$driveLetter\Users"
$excludedUsers = @('Public', 'Default', 'Default User', 'All Users')

Get-ChildItem -Path $usersPath -Directory -ErrorAction SilentlyContinue |
Where-Object { $excludedUsers -notcontains $_.Name } |
ForEach-Object {
    $tempPath = "$($_.FullName)\AppData\Local\Temp\*"
    Remove-Item -Path $tempPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Clean Windows Temp
$winTemp = "$env:windir\Temp\*"
Remove-Item -Path $winTemp -Recurse -Force -ErrorAction SilentlyContinue

# Clean Delivery Optimization cache
$doCachePath = "$driveLetter\ProgramData\Microsoft\Windows\DeliveryOptimization\Cache"
if (Test-Path $doCachePath) {
    Remove-Item "$doCachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
}

# Optional: Clean SoftwareDistribution\Download folder
$updateCache = "$driveLetter\Windows\SoftwareDistribution\Download"
if (Test-Path $updateCache) {
    Remove-Item "$updateCache\*" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Output "🧹 Remediation complete on drive $driveLetter"
exit 0  # Indicate success