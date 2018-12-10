Set ScriptFolder=%~dp0
Set FwfilesFolder=".\..\Source\WinPE\fwfiles"
Set USBFolder=".\..\Deliverable\USB"
Set ISOFolder=".\..\Deliverable\ISO"
Set PETools=".\..\Source\WinPE"

REM Set up the environment
Call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

CD /D %ScriptFolder%

REM Make the ISO
oscdimg -bootdata:2#p0,e,b"%FwfilesFolder%\Etfsboot.com"#pEF,e,b"%FwfilesFolder%\Efisys.bin" -u1 -udfver102 "%USBFolder%" "%ISOFolder%\image.iso 
