$driveLetter = "Z:"
$sharePointURL = "https://yourtenant.sharepoint.com/sites/yoursite/Shared Documents"

# You must authenticate through Internet Explorer / Edge IE mode first
New-PSDrive -Name "Z" -PSProvider FileSystem -Root $sharePointURL -Persist