# Input and output file
$inputPath = "C:\input.txt"
$outputCsv = "C:\AutopilotFormatted.csv"

# Read input lines
$lines = Get-Content $inputPath

# Initialize variables
$serial = ""
$productId = ""
$hwidLines = @()
$collectingHash = $false

foreach ($line in $lines) {
    if ($line -match "Device Serial Number\s*:\s*(.+)") {
        $serial = $matches[1].Trim()
        $collectingHash = $false
    } elseif ($line -match "Windows Product ID\s*:\s*(.*)") {
        $productId = $matches[1].Trim()
        $collectingHash = $false
    } elseif ($line -match "Hardware Hash\s*:\s*(.+)") {
        $hwidLines = @($matches[1].Trim())
        $collectingHash = $true
    } elseif ($collectingHash -and $line -match "\S") {
        $hwidLines += $line.Trim()
    }
}

$hwid = $hwidLines -join ""

# Output final CSV
$csvContent = "Device Serial Number,Windows Product ID,Hardware Hash`n"
$csvContent += "$serial,$productId,$hwid"

Set-Content -Path $outputCsv -Value $csvContent -Encoding UTF8
