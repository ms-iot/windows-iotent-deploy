############################################

##Post deployment script for Windows 10 build

############################################

############################################

##Script Functions

## For test purposes of the script
function Pause
{
	Write-Host -NoNewLine "Press any key to continue..."
	[Console]::ReadKey($true) | Out-Null
	Write-Host
}

# For enabling timeout in script prompts
function Read-HostTimeout ($time, $text, $default)
{
    $startTime = Get-Date
    $timeOut = New-TimeSpan -Seconds $time

    Write-Host $text

    while (-not $host.ui.RawUI.KeyAvailable) 
    {

        $currentTime = Get-Date

        if ($currentTime -gt $startTime + $timeOut) 
        {
            Break
        }
    
    }

    if ($host.ui.RawUI.KeyAvailable) 
    {

        [string]$response = ($host.ui.RawUI.ReadKey("IncludeKeyDown,NoEcho")).character

    }

    else 
    {
        $response = $default
    }

    Return $response
}

#For setting focus for the powershell script
Function Get-Focus{
#bring script back into focus
Add-Type @"
  using System;
  using System.Runtime.InteropServices;
  public class Tricks {
     [DllImport("user32.dll")]
     [return: MarshalAs(UnmanagedType.Bool)]
     public static extern bool SetForegroundWindow(IntPtr hWnd);
  }
"@

$parent = Get-Process -id ((gwmi win32_process -Filter "processid='$pid'").parentprocessid)
If ($parent.Name -eq "cmd") {# Being run by via cmd prompt (batch file)
    $h = (Get-Process cmd).MainWindowHandle
    [void] [Tricks]::SetForegroundWindow($h)
    }
    else{# being run in powershell ISE or console
          $h = (Get-Process -id $pid).MainWindowHandle
          [void] [Tricks]::SetForegroundWindow($h)
    }
} 

############################################

############################################

##Script init

Write-Host "Please wait while the OOBE post deployment script completes."

#Set Focus on the script to accept input
Get-Focus

#Install the latest Windows Defender Update if supplied in the Payload folder
 if (Test-Path -Path $payload\mpam-fe.exe) {Start-Process -FilePath $payload\mpam-fe.exe -Wait}

#Execute the OEM powershell script to allow OEM software applications, utilities, and OS configuration to take place.
Invoke-Expression $payload\OEM_OOBE.ps1

#Set up a run-once to clear out the payload folder after deployment. the Runonce will execute CleanupDeployment.ps1 which removes the C:\Payload\Payload folder.
Invoke-Expression 'reg.exe ADD HKLM\Software\Microsoft\Windows\CurrentVersion\RunOnce /v CleanupDeploymentScript /t REG_SZ /d "Powershell.exe -ExecutionPolicy Unrestricted -File C:\Payload\CleanupDeployment.ps1" /f'

#Reboot the machine
Restart-Computer -Force

