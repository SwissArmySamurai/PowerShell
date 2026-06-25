
$SubscriptionId = "693aea8d-9cb3-4509-b77a-e537e141efec"
$ResourceGroup = "bicepdemos"
$ProjectName = " Migrate Project Name"
$ApplianceName = "ApplianceName"
$DownloadUrl = "https://aka.ms/migrate-appliance"
$InstallerPath = "C:\AzureMigrateAppliance\AzureMigrateInstaller.exe"
$LogPath = "C:\AzureMigrateAppliance\install.log"

Set-ExecutionPolicy RemoteSigned -Scope Process -Force
if (!(Test-Path "C:\AzureMigrateAppliance")) {
    New-Item -ItemType Directory -Path "C:\AzureMigrateAppliance"
}
Invoke-WebRequest -Uri $DownloadUrl -OutFile $InstallerPath
Start-Process -FilePath $InstallerPath -ArgumentList "/quiet /norestart /log $LogPath" -Wait
Install-Module -Name Az -Force -AllowClobber -Scope CurrentUser
Import-Module Az
Connect-AzAccount
Set-AzContext -SubscriptionId $SubscriptionId
Register-AzMigrateAppliance -ResourceGroupName $ResourceGroup -MigrateProjectName $ProjectName -ApplianceName $ApplianceName
Write-Host "Azure Migrate Appliance has been installed and registered successfully!"
