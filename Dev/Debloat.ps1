<#
.SYNOPSIS
    Generalized Windows 11 OEM debloat / decrapifier script.

.DESCRIPTION
    - Dry-run by default; pass -Apply to change the system.
    - Removes common Store/Appx packages (configurable whitelist/blacklist).
    - Removes provisioned Appx packages to prevent reappearing for new users.
    - Optionally enumerates & uninstalls traditional MSI/exe apps (by DisplayName match).
    - Can disable some telemetry/consumer experiences (registry policies).
    - Creates a restore point optionally (if System Restore enabled).
    - Produces a log file.

.NOTES
    - Test in a VM or spare machine first.
    - Some built-in packages cannot be removed; script will skip safely.
    - Requires Administrator rights.

.PARAMETER Apply
    When supplied, script will execute actions. Without it script operates in DryRun mode.

.PARAMETER CreateRestorePoint
    Attempt to create a restore point (default: $true).

.PARAMETER RemoveStoreApps
    Remove modern Store (Appx) apps (default: $true).

.PARAMETER RemoveProvisioned
    Remove provisioned Appx packages (default: $true).

.PARAMETER RemoveTraditional
    Remove legacy (MSI/EXE) apps discovered by DisplayName pattern matching (default: $false).

.PARAMETER TraditionalWhitelist
    Array of strings (partial match) to protect from uninstalls.

.EXAMPLE
    .\Debloat-Win11.ps1                 # Dry run, show planned actions
    .\Debloat-Win11.ps1 -Apply         # Execute removals
#>

param(
    [switch]$Apply,
    [switch]$CreateRestorePoint = $true,
    [switch]$RemoveStoreApps = $true,
    [switch]$RemoveProvisioned = $true,
    [switch]$RemoveTraditional = $false,
    [string[]]$TraditionalWhitelist = @('Microsoft', 'Intel', 'Nvidia', 'AMD', 'Realtek', 'Dell', 'HP', 'Lenovo')
)

# --- Helpers and environment checks ------------------------------------------------
function Assert-Admin {
    if (-not ([bool]([Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) -and
        -not ([Security.Principal.WindowsPrincipal]::new([Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))) {
        Write-Error "This script must be run as Administrator. Right-click > Run as Administrator."
        exit 1
    }
}
Assert-Admin

$ScriptStart = Get-Date
$LogPath = Join-Path $env:LOCALAPPDATA "Debloat-Win11_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$DryRun = -not $Apply

function Log {
    param([string]$Text, [string]$Level='INFO')
    $line = "$(Get-Date -Format 's') [$Level] $Text"
    $line | Tee-Object -FilePath $LogPath -Append
    Write-Output $line
}

Log "Script start. DryRun = $DryRun. Parameters: Apply=$Apply RemoveStoreApps=$RemoveStoreApps RemoveProvisioned=$RemoveProvisioned RemoveTraditional=$RemoveTraditional"

# --- Restore point ----------------------------------------------------------------
function New-RestorePoint-Safe {
    param([string]$Description = "Pre-Debloat")
    if (-not $CreateRestorePoint) { Log "Skipping restore point creation (--CreateRestorePoint false)." ; return }
    try {
        # Check System Restore service
        $svc = Get-Service -Name "srservice" -ErrorAction SilentlyContinue
        if ($null -eq $svc) {
            Log "System Restore service (srservice) not found - cannot create restore point." "WARN"
            return
        }
        if ($svc.Status -ne 'Running') {
            Log "System Restore service is not running. Attempting to start..."
            if ($DryRun) {
                Log "[DryRun] Would start srservice."
            } else {
                Start-Service srservice -ErrorAction Stop
            }
        }
        if ($DryRun) {
            Log "[DryRun] Would create restore point: $Description"
        } else {
            Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
            Log "Restore point created: $Description"
        }
    } catch {
        Log "Failed to create restore point: $_" "ERROR"
    }
}

New-RestorePoint-Safe -Description "Pre-Debloat $(Get-Date -Format 'yyyy-MM-dd HH:mm')"

# --- Appx / Store packages ---------------------------------------------------------
# Whitelist: packages we do NOT want to remove (pattern match)
$AppxWhitelist = @(
    'Microsoft.WindowsCalculator',
    'Microsoft.WindowsStore',
    'Microsoft.MSPaint',
    'Microsoft.DesktopAppInstaller',  # App Installer
    'Microsoft.XboxApp'               # optional — adjust as desired
)
# Blacklist patterns (partial names)
$AppxBlacklistPatterns = @(
    'Xbox', 'CandyCrush', 'Spotify', 'Netflix', 'Zune', 'Microsoft.WindowsAlarms',
    'People', 'Solitaire', 'GetOffice', 'LinkedIn', 'Amazon', 'Booking', 'BingNews', 'Twitter', 'Zillow'
)

function Remove-AppxPackages {
    try {
        $all = Get-AppxPackage -AllUsers
    } catch {
        Log "Get-AppxPackage failed: $_" "ERROR"
        return
    }

    foreach ($p in $all) {
        $fullname = $p.Name
        $display = $p.PackageFullName
        $skip = $false
        foreach ($w in $AppxWhitelist) {
            if ($fullname -like "*$w*") { $skip = $true; break }
        }
        foreach ($pat in $AppxBlacklistPatterns) {
            if ($fullname -like "*$pat*") { $skip = $false; break }
        }
        # also skip Store itself
        if ($fullname -like "*Microsoft.WindowsStore*") { $skip = $true }

        # Determine blacklist membership
        $isBlack = $false
        foreach ($pat in $AppxBlacklistPatterns) {
            if ($fullname -like "*$pat*") { $isBlack = $true; break }
        }

        if ($isBlack -and -not $skip) {
            if ($DryRun) {
                Log "[DryRun] Would remove AppxPackage: $fullname ($display)"
            } else {
                try {
                    # Remove for current user(s)
                    Remove-AppxPackage -Package $display -ErrorAction Stop
                    Log "Removed AppxPackage: $fullname ($display)"
                } catch {
                    Log "Failed removing AppxPackage $display : $_" "WARN"
                }
            }
        } else {
            Log "Keeping AppxPackage: $fullname"
        }
    }
}

if ($RemoveStoreApps) {
    Log "Processing modern Store / Appx packages..."
    Remove-AppxPackages
} else {
    Log "Skipping Store/Appx removals (RemoveStoreApps=false)."
}

# Remove provisioned packages (so new users don't get them)
function Remove-ProvisionedAppx {
    try {
        $prov = Get-AppxProvisionedPackage -Online
    } catch {
        Log "Get-AppxProvisionedPackage failed: $_" "ERROR"
        return
    }
    foreach ($pp in $prov) {
        $name = $pp.DisplayName
        $packname = $pp.PackageName
        $isBlack = $false
        foreach ($pat in $AppxBlacklistPatterns) {
            if ($name -like "*$pat*" -or $packname -like "*$pat*") { $isBlack = $true; break }
        }
        $isWhite = $false
        foreach ($w in $AppxWhitelist) {
            if ($name -like "*$w*" -or $packname -like "*$w*") { $isWhite = $true; break }
        }
        if ($isBlack -and -not $isWhite) {
            if ($DryRun) {
                Log "[DryRun] Would remove provisioned package: $name ($packname)"
            } else {
                try {
                    Remove-AppxProvisionedPackage -Online -PackageName $packname -ErrorAction Stop
                    Log "Removed provisioned package: $name ($packname)"
                } catch {
                    Log "Failed to remove provisioned package $packname : $_" "WARN"
                }
            }
        } else {
            Log "Keeping provisioned package: $name"
        }
    }
}

if ($RemoveProvisioned) {
    Log "Processing provisioned Appx packages..."
    Remove-ProvisionedAppx
} else {
    Log "Skipping provisioned Appx removals (RemoveProvisioned=false)."
}

# --- Telemetry / Consumer Experience tweaks ---------------------------------------
# These are non-invasive policy edits that are commonly used to reduce telemetry and consumer experiences.
#function Set-PrivacyPolicies {
    param($DoIt = $false)
    $keys = @(
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection'; Name='AllowTelemetry'; Value=0},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent'; Name='DisableWindowsConsumerFeatures'; Value=1},
        @{Path='HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsSearch'; Name='AllowCortana'; Value=0}
    )
    foreach ($k in $keys) {
        $path = $k.Path
        $name = $k.Name
        $val  = $k.Value
        if ($DryRun) {
            Log "[DryRun] Would set registry: $path --> $name = $val"
        } else {
            try {
                if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
                New-ItemProperty -Path $path -Name $name -Value $val -PropertyType DWord -Force | Out-Null
                Log "Set registry: $path\$name = $val"
            } catch {
                Log "Failed setting $path\$name : $_" "WARN"
            }
        }
    }
}

Log "Applying privacy/telemetry policy tweaks..."
Set-PrivacyPolicies -DoIt:(!$DryRun)

# --- Scheduled Tasks (OEM / Trial Updaters) ------------
