#The OEM_Audit script is called by Audit.ps1 to install any OEM customizations during the Audit phase.

Push-Location -Path $PSScriptRoot
$payload = $PSScriptRoot

Write-Host "OEM Audit Script"
Start-Sleep -Milliseconds 5000

#Execute the EnablePolicies.ps1 powershell script to enable IoT specific policies.
#Invoke-Expression $payload\EnablePolicies.ps1

#Execute the EnableSecurityBaseline.ps1 powershell script to apply the Windows 10 Security Baseline policies.
#Invoke-Expression $payload\EnableSecurityBaseline.ps1

#Execute the EnableTrafficBaseline.ps1 powershell script to apply the Windows 10 Restricted Traffic Limited Functionality Baseline.
#Invoke-Expression $payload\EnableTrafficBaseline.ps1

Write-Host "Finished OEM Audit Script"

Pop-Location
