@Echo off
@rem Get volume letter of Removable Media to pull image from
@echo.>x:\ListVol.txt
@echo List volume>>x:\ListVol.txt
@echo exit>>x:\ListVol.txt
@echo call diskpart /s x:\ListVol.txt
call diskpart /s x:\ListVol.txt>x:\Output.txt
@echo.
@rem Go through each drive letter, looking for the WIM
for /f "skip=8 tokens=3" %%A in (x:\Output.txt) do (if exist %%A:\Capture.txt set ImagePath=%%A:\)
for /f "skip=8 tokens=3" %%A in (x:\Output.txt) do (if exist %%A:\Payload set OSPath=%%A:\)
@echo.
set ImagePath
set OSPath

call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

Dism /Capture-Image /ImageFile:%OSPath%Base.wim /CaptureDir:%OSPath% /Name:"Windows Base Image"

Dism /Split-Image /ImageFile:%OSPath%Base.wim /SWMFile:%ImagePath%Base.swm /FileSize:3000

Del %OSPath%Base.wim

WPEUtil shutdown
