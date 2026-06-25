# Run in user context
$onedrivePath = "$env:USERPROFILE\OneDrive"
$knownFolders = @("Desktop", "Documents", "Pictures")

$nonRedirected = @()

foreach ($folder in $knownFolders) {
    $target = Join-Path -Path $onedrivePath -ChildPath $folder
    if (-not (Test-Path $target)) {
        $nonRedirected += $folder
    }
}

if ($nonRedirected.Count -eq 0) {
    Write-Output "✅ All known folders are redirected to OneDrive."
    exit 0  # Compliant
} else {
    Write-Output "❌ Not redirected: $($nonRedirected -join ', ')"
    exit 1  # Non-compliant
}

