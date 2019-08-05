#The OEM_OOBE script is called by OOBE.ps1 to install any OEM customizations during the OOBE phase.
Push-Location -Path $PSScriptRoot
$payload = $PSScriptRoot

Write-Host "OEM OOBE Script"
Start-Sleep -Milliseconds 5000

Write-Host "Finished OEM OOBE Script"

Pop-Location
