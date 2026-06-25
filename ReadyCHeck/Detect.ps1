# Exit codes:
# 0 = needs remediation
# 1 = compliant (already Windows 11 or ready for upgrade)

$osVersion = (Get-CimInstance Win32_OperatingSystem).Version

# Exit if already on Windows 11 or higher
if ($osVersion -notlike "10.*") {
    exit 1
}

# Check for Windows 11 readiness registry keys
$regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\TargetVersionUpgradeExperienceIndicators"

if (Test-Path $regPath) {
    $props = Get-ItemProperty -Path $regPath
    if ($props.CompatMode -eq 1 -and $props.UpgEx -eq "Green") {
        exit 1  # Device is ready
    }
}

exit 0  # Not ready
