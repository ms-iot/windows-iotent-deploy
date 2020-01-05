#Sysprep script 

Push-Location -Path $PSScriptRoot
$payload = $PSScriptRoot

#Clear the product key 
Start-Process -FilePath C:\WINDOWS\System32\cscript.exe -ArgumentList " slmgr.vbs /cpky" -Wait

#Execute Sysprep and shutdown the machine
Start-Process -FilePath $env:SystemRoot\System32\Sysprep\Sysprep.exe -ArgumentList "-OOBE -Generalize -Quit -Unattend:$payload\Sysprep.xml" -Wait

#Disable the product key entry screen during OOBE
Start-Process -FilePath $env:SystemRoot\System32\reg.exe -ArgumentList " add HKLM\Software\Microsoft\Windows\CurrentVersion\Setup\OOBE /v SetupDisplayedProductKey /t REG_DWORD /d 1 /f" -Wait

#Shutdown the PC so the image can be capture
Stop-Computer -Force