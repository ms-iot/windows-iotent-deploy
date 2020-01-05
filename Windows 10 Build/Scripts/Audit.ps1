# Audit script installs any pre-req software while in audit mode. The last step is to Sysprep and shutdown the machine. 
# After the system has shutdown DO NOT restart the machine and allow it to boot into Windows. 
# Instead capture the image from the mass storage of the device using WinPE or direct transfer.
# Follow the steps here: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/capture-images-of-hard-disk-partitions-using-dism
# The Payload folder should include a file called OEM_Audit.ps1. The OEM powershell script is customized to include all the installer commands needed
# to install OEM drivers, software applications, utilities and to configure any system settings that should occur in Audit mode.

Push-Location -Path $PSScriptRoot

$payload = $PSScriptRoot

#Install the latest Windows Defender Update if supplied in the Payload folder
if (Test-Path -Path $payload\mpam-fe.exe) {Start-Process -FilePath $payload\mpam-fe.exe -Wait}

#Execute the OEM powershell script to allow OEM software applications, utilities, and OS configuration to take place.
Invoke-Expression $payload\OEM_Audit.ps1

Pop-Location
