# Dynamically detect the system drive (e.g., "C")
$driveLetter = ([System.IO.DirectoryInfo]$env:SystemRoot).Root.Name.TrimEnd("\")  # Returns "C:"

# Set threshold
$requiredFreeGB = 50

try {
    $drive = Get-PSDrive -Name $driveLetter.TrimEnd(":")  # Must strip ":" to get "C" for Get-PSDrive

    if ($null -eq $drive) {
        Write-Output "Drive $driveLetter not found"
        exit 1
    }

    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)

    if ($freeSpaceGB -ge $requiredFreeGB) {
        Write-Output "✅ $driveLetter has enough space: $freeSpaceGB GB"
        exit 0  # Compliant
    } else {
        Write-Output "❌ $driveLetter has only $freeSpaceGB GB free"
        exit 1  # Non-compliant
    }
}
catch {
    Write-Output "❌ Error: $_"
    exit 1
}
