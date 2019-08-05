#General steps for deployment image
#•	Copy base.wim to deployment.wim in  %builddir%\images
#•	Mount %builddir%\images\deployment.wim in %mount%
#•	Copy WinRE.wim from %builddir%\source\WinRE to %mount%\windows\system32\recovery (need to attrib and force)
#•	Copy %builddir%\Payload to %mount%
#•	Add latest cumulative update from %builddir%\Cumulative Updates to %mount%
#•	Copy mpam-fe.exe from %builddir%\Cumulative Updates to %mount%\Payload
#•  Insert the product key
#•	Run Cleanup-Image against %mount%
#•	Unmount %mount% /commit
#•	Export %builddir%\images\deployment.wim to %builddir%\images\deployment-optimized.wim
#•	Delete %builddir%\images\deployment.wim
#•	Rename %builddir%\images\deployment-optimized.wim to %builddir%\images\deployment.wim
#•	Split %builddir%\images\deployment.wim to %builddir%\source\WinPE\media\install.swm Split on 2GB boundary
#•	Copy %builddir%\source\WinPE\media to %builddir%\Deliverable\USB
#•	Run oscdimg against  %builddir%\Deliverable\USB with output to %builddir%\Deliverable\ISO

Push-Location -Path $PSScriptRoot

$builddir = (Get-Item -Path ".\..\" -Verbose).FullName
$mount = (Get-Item -Path ".\..\Mount" -Verbose).FullName
$sources = (Get-Item -Path "..\Source" -Verbose).FullName
$images = (Get-Item -Path ".\..\Images" -Verbose).FullName
$deliverables = (Get-Item -Path "..\Deliverable" -Verbose).FullName

#Cleanup the output folders
Remove-Item -Path $images\Deployment.wim -Force -ErrorAction SilentlyContinue
Remove-Item -Path $images\Deployment-Optimized.wim -Force -ErrorAction SilentlyContinue
Remove-Item -Path $deliverables\USB\* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $deliverables\ISO\* -Recurse -Force -ErrorAction SilentlyContinue

#Check if there SWM files and merge them into the  base WIM if so.
$NewImage = Get-Item -Path "$images\base.swm" -ErrorAction SilentlyContinue
if ($NewImage) {Export-WindowsImage -SourceImagePath $images\base.swm -SourceIndex 1 -DestinationImagePath $images\Base.wim -DestinationName "BaseImage" -SplitImageFilePattern $images\base*.swm}

#Copy base.wim to deployment.wim in $images
Copy-Item -Path $images\Base.wim -Destination $images\Deployment.wim -Force

#Mount %builddir%\images\deployment.wim in %mount%
Mount-WindowsImage -ImagePath $images\Deployment.wim -Index 1 -Path $mount

#Add any Language Pack cabs available in Build\Language Packs
Get-ChildItem -Path "$builddir\Language Packs\*.cab" -Recurse -File | ForEach-Object {Add-WindowsPackage -PackagePath $_ -Path $mount}

#Add any Features on Demand available in Build\Features On Demand
Get-ChildItem -Path "$builddir\Feature On Demand\*.cab" -Recurse -File | ForEach-Object {Add-WindowsPackage -PackagePath $_ -Path $mount}

#Inject the Cumulative Update (if available) into the Deployment.wim.
$CumulativeUpdate = Get-Item -Path "$builddir\Cumulative Updates\*.msu"
if ($CumulativeUpdate) {Add-WindowsPackage -PackagePath $CumulativeUpdate -Path $mount}

#Delete the current WinRE wim file
Remove-Item -Path $mount\Windows\System32\Recovery\Winre.wim -Force

#Add the custom WinRE WIM to the production image
Copy-Item -Path $sources\WinRE\winre.wim -Destination $mount\Windows\System32\Recovery\Winre.wim -Force

#Insert the product key
Set-WindowsProductKey -Path $mount -ProductKey "RKW9C-8NW8G-R4K3M-R664B-F9D8M"

#Unmount %mount% /commit
Dismount-WindowsImage -Path $mount -Save

#Export %builddir%\images\deployment.wim to %builddir%\images\deployment-optimized.wim
Export-WindowsImage -SourceImagePath $images\Deployment.wim -SourceIndex 1 -DestinationImagePath $images\Deployment-Optimized.wim

#Delete %builddir%\images\deployment.wim
Remove-Item -Path $images\Deployment.wim -Force

#Rename %builddir%\images\deployment-optimized.wim to %builddir%\images\deployment.wim
Rename-Item -Path $images\Deployment-Optimized.wim -NewName Deployment.wim -Force

#Split %builddir%\images\deployment.wim to %builddir%\source\WinPE\media\install.swm Split on 2GB boundary
Split-WindowsImage -ImagePath $images\Deployment.wim -SplitImagePath $deliverables\USB\install.swm -FileSize 2000

#Copy %builddir%\source\WinPE\media to %builddir%\Deliverable\USB
Copy-Item -Path $sources\WinPE\media\* -Destination $deliverables\USB -Recurse -Force

#Run oscdimg against  %builddir%\Deliverable\USB with output to %builddir%\Deliverable\ISO
Start-Process -FilePath $builddir\Scripts\MakeBaseISO.bat -Wait -WindowStyle Hidden -PassThru

Pop-Location
