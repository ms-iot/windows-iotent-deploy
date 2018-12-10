# CreateCaptureMedia creates a new WinPE build in the deliverables folder to use when capturing the base OS image.

Push-Location -Path $PSScriptRoot

$builddir = (Get-Item -Path ".\..\" -Verbose).FullName
$mount = (Get-Item -Path ".\..\Mount" -Verbose).FullName
$sources = (Get-Item -Path "..\Source" -Verbose).FullName
$images = (Get-Item -Path ".\..\Images" -Verbose).FullName
$deliverables = (Get-Item -Path "..\Deliverable" -Verbose).FullName


#Cleanup the output folders
Remove-Item -Path $deliverables\USB\* -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $deliverables\ISO\* -Recurse -Force -ErrorAction SilentlyContinue

#Copy %builddir%\source\WinPE\media to %builddir%\Deliverable\USB
Copy-Item -Path $sources\WinPE\media\* -Destination $deliverables\USB -Recurse -Force

#Seed the USB folder with the capture.txt file (we look for this in the WinPE scripts so we know where the USB drive is located).
New-Item $deliverables\USB\Capture.txt -ItemType file

#--- Build the ISO ---#

#Run oscdimg against  %builddir%\Deliverable\USB with output to %builddir%\Deliverable\ISO
Start-Process -FilePath $builddir\Scripts\MakeBaseISO.bat -Wait -WindowStyle Hidden -PassThru
