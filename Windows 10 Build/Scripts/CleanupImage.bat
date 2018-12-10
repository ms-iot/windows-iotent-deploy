Set ScriptFolder=%~dp0

REM Set up the environment
Call "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit\Deployment Tools\DandISetEnv.bat"

cd ..

REM Cleanup the image
DISM /Image:".\Mount" /StartComponentCleanup /ResetBase
