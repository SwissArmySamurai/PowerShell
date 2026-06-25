
$ResourceGroupName = "VM1_group"

Connect-AzAccount

do {
    $resources = Get-AzResource -ResourceGroupName $ResourceGroupName

    if ($resources.Count -eq 0) {
        Write-Host "All resources in '$ResourceGroupName' have been successfully deleted." -ForegroundColor Green
        break
    }

    foreach ($resource in $resources) {
        Write-Host "Deleting resource: $($resource.Name) of type: $($resource.ResourceType)" -ForegroundColor Yellow
        try {
            Remove-AzResource -ResourceId $resource.ResourceId -Force -ErrorAction Stop
            Write-Host "Successfully deleted: $($resource.Name)" -ForegroundColor Green
        } catch {
            Write-Host "Failed to delete: $($resource.Name). Retrying..." -ForegroundColor Red
        }
    }

    Start-Sleep -Seconds 5

} while ($true)  # Keep looping until all resources are deleted
