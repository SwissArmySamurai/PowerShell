# Check if System Protection is enabled on C:\
$enabled = Get-ComputerRestorePoint -ErrorAction SilentlyContinue

if ($enabled) {
    Write-Output "System Protection already enabled"
    exit 0  # Compliant
} else {
    Write-Output "System Protection NOT enabled"
    exit 1  # Not compliant
}