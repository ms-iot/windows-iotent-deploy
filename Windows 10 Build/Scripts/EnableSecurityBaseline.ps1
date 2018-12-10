#Installs the Windows 10 Security Baseline. Note: The path in $sec_baseline_script should be updated if a different 
#Security Baseline package is used. The path below is based on extracting the contents of the Windows 10 Securty Baseline available here https://www.microsoft.com/en-us/download/details.aspx?id=55319 
# to Windows 10 Build\Payload\Payload\Preinstall\Windows-10-RS1-and-Server-2016-Security-Baseline

#The baseline can be installed in either setup phase (OOBE or Audit). If installed during Audit the default user account created during OOBE must meet the password minimum requirements set
#by the policy baseline. If installed during OOBE any user accounts with passwords that do not meet the requirements will require having their password udpated.

#Uncomment the commands below to install the Windows 10 Security Baseline. This script should be run as part of the OEM_Audit.ps1 or the OEM_OOBE.ps1.

Push-Location -Path $PSScriptRoot

$sec_baseline_script = (Get-Item -Path ".\PreInstall\Windows-10-RS1-and-Server-2016-Security-Baseline\Local_Script\Client_Install.cmd" -Verbose).FullName

# Install the Windows 10 Security baseline on the machine. Note, there is an error created when piping in the character to start the script. 
# The error can be ignored and the baseline is being applied correctly.
"X" | cmd /c $sec_baseline_script