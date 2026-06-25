$DriveLetter = "H"
$NetworkSharePath = "\\10.10.60.91\"
$CurrentUser = $env:UserName 
$Domain = "CORPADS.ADGUS.NET"

$Password = Read-Host -AsSecureString "Enter your password for domain $Domain"

# Create a PSCredential object with the new domain and the current user's username
$Credential = New-Object System.Management.Automation.PSCredential("$Domain\$CurrentUser", $Password)

# Remove any existing mapping for the same drive letter
if (Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue) {
    Remove-PSDrive -Name $DriveLetter -Force -ErrorAction SilentlyContinue
}

# Map the network drive using credentials from the other domain
New-PSDrive -Name $DriveLetter -PSProvider FileSystem -Root $NetworkSharePath -Persist -Credential $Credential
