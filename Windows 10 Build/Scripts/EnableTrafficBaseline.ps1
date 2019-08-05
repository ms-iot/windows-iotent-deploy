#Installs the Windows 10 Restricted Traffic Limited Functionality Baseline. Note: The path in $traffic_baseline_script should be updated if a different 
#Restricted Traffic Baseline package is used. The path below is based on extracting the contents of the Windows 10 Restricted Traffic Limited Functionality Baseline available here https://go.microsoft.com/fwlink/?linkid=828887
# to Windows 10 Build\Payload\Payload\Preinstall\Restricted Traffic Limited Functionality Baseline

#Uncomment the commands below to install the Windows 10 Restricted Traffic Limited Functionlity Baseline. This script should be run as part of the OEM_Audit.ps1 or the OEM_OOBE.ps1.

Push-Location -Path $PSScriptRoot

$traffic_baseline_script = (Get-Item -Path ".\PreInstall\Restricted Traffic Limited Functionality Baseline\RestrictedTraffic_Client_Install.cmd" -Verbose).FullName

# Install the Restricted Traffic Limited Functionality Baseline. Note, there is an error created when piping in the character to start the script. 
# The error can be ignored and the baseline is being applied correctly.
"X" | cmd /c $traffic_baseline_script

Pop-Location
