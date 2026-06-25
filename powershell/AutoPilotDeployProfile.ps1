# Connect to Microsoft Graph with required scope
Connect-MgGraph -Scopes "DeviceManagementServiceConfig.ReadWrite.All"

#AutoPilot Enrollment Profile Settings
$profile = @{
    "@odata.type" = "#microsoft.graph.azureADWindowsAutopilotDeploymentProfile"
    displayName = "ADG_CSRM_<BU>_DEPLOYMENT"  #---------------------------------------------------Change this
    description = "Baseline deployment Policy for endpoint deployment."
    deviceType = "windowsPc"
    deviceNameTemplate = "<BU>-%SERIAL%" #---------------------------------------------------Change this
    preprovisioningAllowed = $false
    extractHardwareHash = $true
    enableWhiteGlove = $false
    hardwareHashExtractionEnabled = $true
    language = "en-US"
    locale = "en-US"
    roleScopeTagIds = @("0")  # You can leave this empty or change to your real tag ID
    outOfBoxExperienceSettings = @{
        hideEULA = $true
        hideEscapeLink = $true
        skipKeyboardSelectionPage = $true
        deviceUsageType = "singleUser"
        userType = "standard"
        hidePrivacySettings = $true
    }
    # enrollmentStatusScreenSettings = $null  # Optional, exclude if not set
}

#JSON conversion required for Graph API
$jsonBody = $profile | ConvertTo-Json -Depth 10 -Compress

#Post request to the API
$response = Invoke-MgGraphRequest `
    -Method POST `
    -Uri "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeploymentProfiles" `
    -Body $jsonBody `
    -ContentType "application/json"
