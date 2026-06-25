# Set execution policy for the current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Install the required script
Install-Script -Name Get-WindowsAutopilotInfo -Force

# Export HWID to a CSV file
Get-WindowsAutopilotInfo -OutputFile "C:\HWID.csv"
