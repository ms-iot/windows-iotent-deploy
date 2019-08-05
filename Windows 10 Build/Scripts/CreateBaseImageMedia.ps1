# CreateBaseImage script creates the initial output in the Deliverable folder that is used to bring up the reference machine.
# There are two folders in the Deliverable folder - 1) ISO and 2) USB. The USB folder contains output suitable for copying to a USB flash drive
# Copy the contents of \Deliverable\USB to a bootable USB flash drive and boot the reference machine from USB. Setup is automated.
# The ISO folder is a bootable ISO version of the output that can be used to quickly bring up Hyper-V virtual machines or to bring up a 
# reference device with an optical drive.

Push-Location -Path $PSScriptRoot

$builddir = (Get-Item -Path ".\..\" -Verbose).FullName
$mount = (Get-Item -Path ".\..\Mount" -Verbose).FullName
$sources = (Get-Item -Path "..\Source" -Verbose).FullName
$images = (Get-Item -Path ".\..\Images" -Verbose).FullName
$drivers = (Get-Item -Path ".\..\Drivers" -Verbose).FullName
$policies = (Get-Item -Path ".\..\Policies" -Verbose).FullName
$deliverables = (Get-Item -Path "..\Deliverable" -Verbose).FullName
$answerfile = "$builddir\Answer Files\64Bit_UEFI_UnattendedSetup.xml"
$sysprep_answerfile = "$builddir\Answer Files\Sysprep.xml"

#Cleanup the output folders
Remove-Item -Path $deliverables\USB\* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $deliverables\ISO\* -Recurse -Force -ErrorAction SilentlyContinue

#Copy %builddir%\source\WinPE\media to %builddir%\Deliverable\USB
Copy-Item -Path $sources\ISO\* -Destination $deliverables\USB -Recurse -Force

#Copy the unattend XML to the USB folder. This will also be included in the ISO that is created
Copy-Item -Path $answerfile -Destination $deliverables\USB\AutoUnattend.xml -Force

#--- Copying scripts to Payload folder of deployment media ---#

#Copy the Sysprep XML to the Payload folder. This is used to Sysprep the reference machine after Audit mode activities are completed.
#Note: The double \Payload\Payload path is intended. The data WIM captures the folder $builddir\Payload which keeps the software payload 
# in a subfolder called Payload on the root of the mass storage of the reference machine.
Copy-Item -Path $sysprep_answerfile -Destination $builddir\Payload\Payload\Sysprep.xml -Force

#Copy the OEM_Audit.ps1 script to the Payload folder. This script will be launched automatically by the Audit mode script.
#OEM's should custiomize the OEM.ps1 script to install any software applications, utilities, or to make any system configurations that need to happen in
#the Audit phase of setup
Copy-Item -Path $builddir\Scripts\OEM_Audit.ps1 -Destination $builddir\Payload\Payload\OEM_Audit.ps1 -Force

#Copy the OEM_OOBE.ps1 script to the Payload folder. This script will be launched automatically by the OOBE mode post deployment script.
#OEM's should custiomize the OEM.ps1 script to install any software applications, utilities, or to make any system configurations that need to happen in
#the OOBE phase of setup
Copy-Item -Path $builddir\Scripts\OEM_OOBE.ps1 -Destination $builddir\Payload\Payload\OEM_OOBE.ps1 -Force

#Copy the Audit.ps1 script to the Payload folder. This script will be started automatically during the Audit phase of setup. 
Copy-Item -Path $builddir\Scripts\Audit.ps1 -Destination $builddir\Payload\Payload\Audit.ps1 -Force

#Copy the OOBE.ps1 script to the Payload folder. This script will be started automatically during the OOBE phase of setup. The OOBE script installs
#software, applications and policies and launches the OEM_OOBE powershell.
Copy-Item -Path $builddir\Scripts\OOBE.ps1 -Destination $builddir\Payload\Payload\OOBE.ps1 -Force

#Copy the Sysprep.ps1 script to the Payload folder. This script will be started by the user after Audit mode is completed.
#The Sysprep script syspreps the system and shutsdown the terminal
Copy-Item -Path $builddir\Scripts\Sysprep.ps1 -Destination $builddir\Payload\Payload\Sysprep.ps1 -Force

#Copy the EnablePolicies.ps1 script to the Payload folder. This script will be launched automatically by the Audit mode script.
#This script enables any IoT Specific policies that are needed by the OEM.
Copy-Item -Path $builddir\Scripts\EnablePolicies.ps1 -Destination $builddir\Payload\Payload\EnablePolicies.ps1 -Force

#Copy the Policies in Build\Policies
Copy-Item -Path $policies -Destination $builddir\Payload\Payload\ -Recurse -Force

#Copy the EnableSecurityBaseline.ps1 script to the Payload folder. This script will be launched automatically by the Audit mode script.
#This script applies the Windows 10 Security Baseline policies.
Copy-Item -Path $builddir\Scripts\EnableSecurityBaseline.ps1 -Destination $builddir\Payload\Payload\EnableSecurityBaseline.ps1 -Force

#Copy the EnableTrafficBaseline.ps1 script to the Payload folder. This script will be launched automatically by the Audit mode script.
#This script applies the Windows 10 Restricted Traffic Limited Functionality policies.
Copy-Item -Path $builddir\Scripts\EnableTrafficBaseline.ps1 -Destination $builddir\Payload\Payload\EnableTrafficBaseline.ps1 -Force

#Copy the CleanupDeployment.ps1 script to the Payload folder. This script will be scheduled to run automatically by the OOBE mode script through a RunOnce registry item.
#This script cleans up the payload folder.
Copy-Item -Path $builddir\Scripts\CleanupDeployment.ps1 -Destination $builddir\Payload\Payload\CleanupDeployment.ps1 -Force


#--- Capture the Payload WIM and add to the image ---#
#Create the Payload WIM that is deployed to the base image.
Start-Process -FilePath C:\Windows\System32\Dism.exe -ArgumentList "/capture-image /capturedir=`"$builddir\Payload`" /imagefile=`"$builddir\Deliverable\USB\Payload.wim`" /noacl=all /name=Payload" -Wait -WindowStyle Hidden

#--- Service the install WIM with Language Packs, Features on Demand and Cumulative Updates ---#

#Mount %builddir%\deliverable\USB\sources\install.wim in %mount%
Mount-WindowsImage -ImagePath $builddir\Deliverable\USB\Sources\install.wim -Index 1 -Path $mount

#Add any Language Pack cabs available in Build\Language Packs
Get-ChildItem -Path "$builddir\Language Packs\*.cab" -Recurse -File | ForEach-Object {Add-WindowsPackage -PackagePath $_ -Path $mount}

#Add any Features on Demand available in Build\Features On Demand
Get-ChildItem -Path "$builddir\Feature On Demand\*.cab" -Recurse -File | ForEach-Object {Add-WindowsPackage -PackagePath $_ -Path $mount}

#Add any drivers available in Build\Drivers
Add-WindowsDriver -Path $mount -Driver $drivers -Recurse

#Unmount %mount% /commit
Dismount-WindowsImage -Path $mount -Save

#Export %builddir%\images\deployment.wim to %builddir%\images\deployment-optimized.wim
Export-WindowsImage -SourceImagePath $builddir\Deliverable\USB\Sources\install.wim -SourceIndex 1 -DestinationImagePath $builddir\Deliverable\USB\Sources\install-Optimized.wim

#Delete %builddir%\images\deployment.wim
Remove-Item -Path $builddir\Deliverable\USB\Sources\install.wim -Force

#Rename %builddir%\images\deployment-optimized.wim to %builddir%\images\deployment.wim
Rename-Item -Path $builddir\Deliverable\USB\Sources\install-Optimized.wim -NewName Install.wim -Force

#--- Build the ISO ---#

#Run oscdimg against  %builddir%\Deliverable\USB with output to %builddir%\Deliverable\ISO
Start-Process -FilePath $builddir\Scripts\MakeBaseISO.bat -Wait -WindowStyle Hidden -PassThru

Pop-Location
