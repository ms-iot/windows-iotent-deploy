#BuildWinPE creates the WinPE and WinRE sources for the deployment media. The script assumes the Windows 10 ADK is installed

Push-Location -Path $PSScriptRoot

$builddir = (Get-Item -Path ".\..\" -Verbose).FullName
$mount = (Get-Item -Path ".\..\Mount" -Verbose).FullName
$sources = (Get-Item -Path "..\Source" -Verbose).FullName
$images = (Get-Item -Path ".\..\Images" -Verbose).FullName
$deliverables = (Get-Item -Path "..\Deliverable" -Verbose).FullName

function Import-Environment 
{
    param(
        [parameter(mandatory=$true)]
        [string]$batch
    )
    $dump = cmd /c "`"$batch`" 1>nul && set"
    $dump | ForEach-Object {
        $s = $_ -split '='
        Write-Verbose ("Var {0} = {1}" -f $s[0],$s[1])
        [System.Environment]::SetEnvironmentVariable($s[0],$s[1])
    }
}

#Cleanup the source folders in case a previous WInPE is present
Remove-Item -Path $sources\WinPE -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path $sources\WinRE -Recurse -Force -ErrorAction SilentlyContinue

#Run CopyPE from the Windows 10 ADK to create the new WinPE image
Import-Environment 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat'
cmd @("/c", 'C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Windows Preinstallation Environment\copype.cmd', "amd64", "C:\PE")
Move-Item -Path C:\PE -Destination $sources\WinPE

#Mount the WinPE boot WIM and copy the customized startnet, deployimage and diskpart scripts
Mount-WindowsImage -ImagePath $sources\WinPE\media\sources\boot.wim -Index 1 -Path $mount

Copy-Item -Path $builddir\Scripts\Deploy.bat -Destination $mount\Windows\System32
Copy-Item -Path $builddir\Scripts\Capture.bat -Destination $mount\Windows\System32
Copy-Item -Path $builddir\Scripts\Diskpart-Deploy.txt -Destination $mount\Windows\System32\Diskpart.txt

#Add any drivers available in Build\Drivers
Add-WindowsDriver -Path $mount -Driver $drivers -Recurse

#Unmount %mount% /commit
Dismount-WindowsImage -Path $mount -Save

#Make a copy of the WinPE boot WIM to use as a recovery WIM
New-Item -Path $sources -Name WinRE -ItemType directory
Copy-Item -Path $sources\WinPE\media\sources\boot.wim $sources\WinRE\winre.wim -Force

#Mount the WinRE boot WIM and copy the customized startnet, recoverimage and diskpart scripts
Mount-WindowsImage -ImagePath $sources\WinRE\winre.wim -Index 1 -Path $mount
Copy-Item -Path $builddir\Scripts\Recover.bat -Destination $mount\Windows\System32
Copy-Item -Path $builddir\Scripts\Diskpart-Recover.txt -Destination $mount\Windows\System32\Diskpart.txt
Copy-Item -Path $builddir\Scripts\startnet-recover.cmd -Destination $mount\Windows\System32\startnet.cmd

#Unmount %mount% /commit
Dismount-WindowsImage -Path $mount -Save

Pop-Location
