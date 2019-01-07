# windows-iotent-deploy

<b>Quick Start Guide</b>

The easiest way to get started with the deployment framework is to complete the steps in this Quick Start Guide on a reference device. After completing the steps, move on to more advanced topics outlined below.

For the purposes of this guide, we use the term builddir to indicate the folder on the development machine where the deployment framework is stored. The folder structure should be a top level folder named <b>Windows 10 Build</b> (this is the builddir, it can be renamed to anything you like) with subfolders named Answer Files, Cumulative Updates, Deliverable, etc... The subfolders need to stay named the same as they are in the repo. Also, in this guide, the term reference device is used to describe the IoT target device and development machine is used to describe the system where the scripting framework resides.

1) Download the files from the repository and extract the zip to a folder on your development machine.
2) Install the latest **Windows ADK for Windows 10** and the **WinPE add-on for the ADK** available here: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
3) Open an administrative powershell command prompt and run <b>builddir\scripts\SetupEnvironment.ps1</b>. You may need to run <b>SetupEnvironment.ps1 -ExecutionPolicy bypass</b> in order to run successfully.  SetupEnvironment creates the intial folder layout for the framework. Folders below builddir need to stay named the same way in order for the framework to work properly. Note: If prompted, type <b>R</b> and press enter to run the script.
4) Obtain an ISO of Windows 10 IoT Enterprise. This is available from your IoT distributor (indirect OEM partners) or online via the Microsoft Digital Operations Center website (direct OEM partners). Mount the ISO and extract the contents to builddir\Source\ISO. Note: If you are not a registered OEM and want to experiment with the deployment framework, an MSDN ISO of Windows 10 Enterprise will suit here as well. Just be sure to get signed up as an OEM with one of our distributors, get official media and rebuild your image before shipping your device. 
5) Many of the policies deployed use a utility called LGPO. LGPO is made available as part of the Microsoft Security Compliance Toolkit. Download LGPO.zip from the Microsoft Security Compliance Toolkit page: https://www.microsoft.com/en-us/download/details.aspx?id=55319 Extract LGPO.exe to builddir\Payload\Payload. The utility will be used to install preconfigured script files as part of the framework. You can also use LGPO to add policies of your own. See the steps in the Advanced Topics below for adding a policy to the build using LGPO.
6) From the administrative powershell command prompt run <b>builddir\scripts\BuildWinPE.ps1</b>. BuildWinPE creates the initial WinPE and WinRE bootable images that are used throughout the deployment framework process.
7) From the administrative powershell command prompt run <b>builddir\scripts\CreateBaseImageMedia.ps1</b>. CreateBaseImageMedia copies the source from builddir\source\ISO to the Deliverable folder, adds the scripting for the framework and the Answer Files used by Windows setup, and makes a few configuration changes. In the Deliverable folder you will find two subfolders named ISO and USB. The ISO folder will contain a bootable ISO to be used to install the OS image to either a Virtual Machine or a reference device with an optical drive. The USB folder will contain a set of bootable files used to install the OS image to a reference device via USB.
8) Plug a FAT32 formatted USB drive into the development machine. The drive should be at least 16GB in size or larger. Copy the contents of builddir\Deliverable\USB to the USB drive. Remove the USB drive from the development machine. Boot the reference device from the USB stick. Windows setup begins and completes the initial install of the OS. This portion of the installation ends in Audit Mode: https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/boot-windows-to-audit-mode-or-oobe
9) In your full production environment Audit Mode would be used to install any software, drivers, utilities, etc... that should be part of the base OS image. The base OS image is the image that will be common to all your devices. This image does not change very often. Examples of when it might change would be new requirements for software or drivers to be pre-installed, or when moving to a new version of Windows 10. For the purpose of this Quick Start Guide you are going to move directly to the Sysprep process. While in Audit Mode, close the Sysprep dialog that is displayed automatically on startup. Open an Administrative Command Prompt and run <b>powershell -executionpolicy unrestricted -f C:\Payload\Sysprep.ps1</b>. This script will complete the Sysprep process and shut the system down. <b>Important: Do not power the system back on at this point!</b>
10) On the development machine open an administrative powershell command prompt and run <b>builddir\scripts\CreateCaptureMedia.ps1</b>. This will create a WinPE build in the builddir\Deliverable folder that can be used to capture the OS image that was Sysprepped the previous steps. Plug a FAT32 formatted USB drive into the development machine. This can be the same drive used earlier or a second drive. If using the same drive as earlier steps the contents of the USB drive should be deleted or the drive should be formatted so that it is empty. Copy the contents of builddir\Deliverable\USB to the USB drive. Remove the USB drive from the development machine. Boot the reference device from the USB stick. WinPE will start and a command prompt is displayed. In the commmand prompt type <b>capture</b> and press Enter. The capture script will detect the USB drive and the OS installation drive and proceed to capture an image of the OS. This is now the base image to be used in the rest of the development process. After the capture is completed the system will shutdown.
11) Move the USB drive from the reference device to the development machine. Open the USB drive in file explorer and copy Base.swm, Base1.swm, Base2.swm (etc...) to builddir\Images.
12) On the development machine open an administrative powershell command prompt and run <b>builddir\scripts\CreateProductionImageMedia.ps1</b>. CreateProductionImageMedia copies WinPE and the customized OS image to the builddir\Deliverable folder in both USB and ISO format. Normally the CreateProductionImageMedia would also add updates, Features on Demand, Language Packs, etc.. to the image. For the Quick Start Guide the goal is just to get you familiar with the overall process. Advanced topics below give links to how to take full advantage of the framework features. Copy the contents of builddir\Deliverable\USB to the USB drive. Remove the USB drive from the development machine. Boot the reference device from the USB stick. WinPE will start and a command prompt is displayed. In the commmand prompt type <b>deploy</b> and press Enter. The capture script will detect the USB drive and proceed to deploy the production image on the reference device. The device will reboot automatically when this step is completed. The system will now boot through and automated OOBE and complete at the desktop. Note: The auto logon user created by the deployment framework is named <b>User</b> with a password of <b>!@#Secret123#@!</b>. Of course this can all be customized following the advanced topics below.

Congratulations. You've just completed the first part of using the deployment framework to help with building your OS image. More advanced topics like automating software installation, automating driver installation, setting policies, etc... are outlined below.

<b>Advanced Topics</b>

**Adding your own Embedded Product Key (ePKEA) to the build process**

You can add your own OEM key to the build process so that it is injected during the Audit phase of setup. 

1) Open builddir\scripts\CreateProductionMedia.ps1 in Powershell ISE or a text editor. 
2) Locate the following line and replace the default key (RKW9C-8NW8G-R4K3M-R664B-F9D8) with the appropriate 5x5 key you were provided.

Set-WindowsProductKey -Path $mount -ProductKey "RKW9C-8NW8G-R4K3M-R664B-F9D8M"

3) Save CreateProductionMedia.ps1
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1 if you are starting a new build or CreateProductionImageMedia.ps1 if you are editing an already captured build.

**Changing the default password for the auto generated user account**

During the OOBE phase of setup the user created has a hard-coded name and password. These should be changed to something private to the OEM. To modify the password follow the steps below:

1) Open builddir\Answer Files\Sysprep.xml in a text editor.
2) Locate the following XML and change the Password value and optionally the User name and description.

			<UserAccounts>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>!@#Secret123#@!</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Description>User</Description>
                        <DisplayName>User</DisplayName>
                        <Name>User</Name>
                        <Group>Administrators</Group>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>

3) Next, locate the following XML and change the Autologon information to match the changes to the username and password above.

			<AutoLogon>
                <Password>
                    <Value>!@#Secret123#@!</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>9999</LogonCount>
                <Username>User</Username>
            </AutoLogon>

4) Save Sysprep.xml.
5) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide.

**Adding a new Language Pack to the image**

You can add Language Packs to the image automatically using the framework. Both the CreateBaseImageMedia and the CreateProductionImageMedia will search the Language Pack folder in \builddir for applicable Language Pack cabs to add to the image.

1) Obtain the Language Pack DVD / ISO from your distributor (indirect OEM partners) or online via the MyOEM website (direct OEM partners).
2) Mount the ISO and locate the cab file for the language desired. Note: You can add multiple language packs at the same time. For example, to add French Language Pack locate the file named Microsoft-Windows-Client-Language-Pack_x64_fr-fr.cab.
3) Copy the CAB file to builddir\Language Packs.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1 if you are starting a new build or CreateProductionImageMedia.ps1 if you are editing an already captured build. The Language Pack cabs will be added to the image automatically.

**Adding a new Feauture on Demand (FoD) to the image**

You can add Feature on Demand packages to the image automatically using the framework. Both the CreateBaseImageMedia and the CreateProductionImageMedia will search the Feature On Demand folder in \builddir for applicable FoD cabs to add to the image.

1) Obtain the Feature on Demand DVD / ISO from your distributor (indirect OEM partners) or online via the MyOEM website (direct OEM partners).
2) Mount the ISO and locate the cab file for the feature desired. Note: You can add multiple features at the same time. For example, to add support for Developer Mode to the image locate the file named Microsoft-OneCore-DeveloperMode-Desktop-Package.cab.
3) Copy the CAB file to builddir\Feature on Demand.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1 if you are starting a new build or CreateProductionImageMedia.ps1 if you are editing an already captured build. The Feature cabs will be added to the image automatically.

**Adding the latest cumulative update to the build process**

The latest cumulative update (LCU) can be added to the build framework to make it easier to deploy the latest bugfixes and security fixes. The LCU packages are availble on the Microsoft Update Catalog: https://www.catalog.update.microsoft.com/Home.aspx. If you are unsure which update is the latest cumulative for your platform, refer to the Windows 10 Update History here: https://support.microsoft.com/en-us/help/4099479/windows-10-update-history. Choose your version from the menu on the left and select the latest cumulative update in the list. Once you have located the latest cumulative upadte on the Windows 10 Update History site, scroll to the bottom of the page and select the link to get the stand-alone package for the update on the Microsoft Update Catalog site. The download is in .MSU format.

1) Download the MSU package from the Microsoft Update Catalog.
2) Copy the MSU file to builddir\Cumulative Updates.
3) Open an administrative powershell command prompt and run builddir\scripts\CreateProductionImageMedia.ps1. The update will be injected into the image automatically.

Note: This assumes the Quick Start Guide was followed an the initial base image was captured using WinPE. If you have not completed the Quick Start Guide refer to the steps at the top of this document.

**Adding a new custom Audit mode command to the build process**

There are scenarios where adding custom commands during the Audit phase of setup are desired. The deployment framework provides an entrypoint for adding custom commands in the builddir\scripts\OEM_Audit.ps1 script. This script is launched automatically by the builddir\scripts\Audit.ps1 script. Examples of commands that might need to be run during Audit mode include adding drivers via driver installers, installing OEM software, installing 3rd party software and utilities, etc... The OEM_Audit.ps1 script can be edited and commands added just as you would type them normally in a Powershell command prompt. Note that whatever is added to the script should be fully automated if that is the desired experience. Running software and driver installers with their appropriate silent switches could be required, for example.

**Adding a new custom OOBE mode command to the build process**

There are scenarios where adding custom commands during the OOBE phase of setup are desired. The deployment framework provides an entrypoint for adding custom commands in the builddir\scripts\OEM_OOBE.ps1 script. This script is launched automatically by the builddir\scripts\OOBE.ps1 script. Examples of commands that might need to be run during Audit mode include adding drivers via driver installers, installing OEM software, installing 3rd party software and utilities, etc... The OEM_OOBE.ps1 script can be edited and commands added just as you would type them normally in a Powershell command prompt. Note that whatever is added to the script should be fully automated if that is the desired experience. Running software and driver installers with their appropriate silent switches could be required, for example.

**Adding your own binaries to the build process**

There are sceanrios where you need to stage your own binaries on the system to run from the scripts in Audit and OOBE. For example, you may want to include a driver installer named driver.msi and run it during Audit mode. The steps below describe how to stage the binaries in the build system and then execute them during install. The example is in Audit mode but the same applies for OOBE, just edit the appropriate OEM_OOBE.ps1 instead of OEM_Audit.ps1 to add your custom commands.

1) Copy the binaries to builddir\Payload\Payload (note the nested folders are requred). For example, copy driver.msi to builddir\Payload\Payload.
2) Edit builddir\scripts\OEM_Audit.ps1 to add a command which will run the driver installer. For example, add "Invoke-Expression $payload\driver.msi" . Note: The driver.msi file will be copied to C:\Payload as part of the install process.
3) Save OEM_Audit.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide. The driver installer will run as part of the Audit phase of setup.

**Enabling Shell Launcher**

The Shell Launcher feature allows the OEM to specify a Win32 (.NET, C++. etc...) application as the system shell. The feature also allows the OEM to configure specific actions that the system should take in the event the shell application exits (or crashes). There are several entry points where Shell Launcher could be configured during the deployment process. The steps below show how to modify the OEM_OOBE.ps1 script to configure Shell Launcher automatically as part of the build process.

1) Open builddir\scripts\OEM_OOBE.ps1 in Powershell ISE or a text editor.
2) Add the following lines to the OEM_OOBE.ps1 script. Replace notepad.exe with your OEM application executable.

```Powershell Enable-WindowsOptionalFeature -Online -FeatureName "Client-EmbeddedShellLauncher " -All
$ShellLauncherClass = [wmiclass]"\\localhost\root\standardcimv2\embedded:WESL_UserSetting"
$ShellLauncherClass.SetDefaultShell("notepad.exe",1)
$ShellLauncherClass.SetEnabled($TRUE)
```

3) Save OEM_OOBE.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1 if you are starting a new build or CreateProductionImageMedia.ps1 if you are editing an already captured build.

**Updating the image with the latest Windows Defender definition updates**

The deployment framework provides a way to udpate Windows Defender definitions as part of the deployment process. This normally happens in Audit mode. Follow the steps below to update the base OS image with the latest definitions.

1) Download the latest definition file from the definition site: https://www.microsoft.com/en-us/wdsi/definitions. Be sure to choose the right CPU architecture. The file is named mpam-fe.exe and should not be changed.
2) Copy mpam-fe.exe to builddir\payload\payload.
3) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide. The definition update will run as part of the Audit phase of setup.

Note: There is also an option to update the definitions as part of OOBE. This is useful if you want to just update the definitiions without going back and rebuilding the entire base image. Follow the steps below to update the production OS image with the latest definitions.

1) Download the latest definition file from the definition site: https://www.microsoft.com/en-us/wdsi/definitions. Be sure to choose the right CPU architecture. The file is named mpam-fe.exe and should not be changed.
2) Copy mpam-fe.exe to builddir\payload\payload.
3) Open an administrative powershell command prompt and run builddir\scripts\CreateProductionImageMedia.ps1 to update the existing production build. The definitions will be updated the next time the image is deployed.

**Making Windows Update notifications silent**

There are scenarios where the desire is to allow Windows Update to automatically update devices but also to suppress all the UI created as part of the update proceess. To suppress the Windows Update notifications follow the steps below:

1) Open builddir\scripts\EnablePolicies.ps1 in Powershell ISE or a text editor.
2) Locate and uncomment the following line

#Start-Process -FilePath "$env:SystemDrive\Payload\Payload\LGPO\LGPO.exe" -ArgumentList "/m $env:SystemDrive\Payload\Payload\SetUpdateNotificationLevel.pol" -WindowStyle Hidden -Wait

3) Save EnablePolicies.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide.

**Disabling SmartScreen on the device**

There are scenarios where Windows Defender Smart Screen may create unwanted UI in the browser. To disable Windows Defender Smart Screen follow the steps below.

1) Open builddir\scripts\EnablePolicies.ps1 in Powershell ISE or a text editor.
2) Locate and uncomment the following line

#Start-Process -FilePath "$env:SystemDrive\Payload\Payload\LGPO\LGPO.exe" -ArgumentList "/m $env:SystemDrive\Payload\Payload\DisableSmartScreen.pol" -WindowStyle Hidden -Wait

3) Save EnablePolicies.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide.

**Disabling Delivery Optimization**

Delivery Optimization is a feature that improves the performance of delivering updates to devices. Part of the capabilities of Delivery Optimization is to specify download locations for updates, including downloading from peer devices. This may not be a desired feature if the IoT device is on the same LAN with other WIndows devices which are not managed in the same way. To disable peer download follow the steps below:

1) Open builddir\scripts\EnablePolicies.ps1 in Powershell ISE or a text editor.
2) Locate and uncomment the following line

#Start-Process -FilePath "$env:SystemDrive\Payload\Payload\LGPO\LGPO.exe" -ArgumentList "/m $env:SystemDrive\Payload\Payload\DeliveryOptimization.pol" -WindowStyle Hidden -Wait

3) Save EnablePolicies.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide.

**Windows Defender UI Optimization**

There are scenarios where Windows Defender real time scanning is desired, but the WIndows Defender UI should never be shown. This allows the device to be protected by basic level Windows Defender capabilities while preserving the device user experience. To configure WIndows Defender to show no UI follow the steps below:

1) Open builddir\scripts\EnablePolicies.ps1 in Powershell ISE or a text editor.
2) Locate and uncomment the following line

#Start-Process -FilePath "$env:SystemDrive\Payload\Payload\LGPO\LGPO.exe" -ArgumentList "/m $env:SystemDrive\Payload\Payload\DefenderSettings.pol" -WindowStyle Hidden -Wait

3) Save EnablePolicies.ps1.
4) Open an administrative powershell command prompt and run builddir\scripts\CreateBaseImageMedia.ps1. Complete the deployment steps in the quick start guide.

**
