$OneDriveSetup = "$env:SystemDrive\Program Files\Microsoft OneDrive\OneDrive.exe"
Start-Process "$OneDriveSetup" "/silent"
Start-Process "$OneDriveSetup" "/configurebusiness:<TenantID>"  # Optional if using XML
