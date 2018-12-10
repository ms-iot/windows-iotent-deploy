@Echo off
@rem Get volume letter of Removable Media to pull image from
@echo.>x:\ListVol.txt
@echo List volume>>x:\ListVol.txt
@echo exit>>x:\ListVol.txt
@echo call diskpart /s x:\ListVol.txt
call diskpart /s x:\ListVol.txt>x:\Output.txt
@echo.
@rem Go through each drive letter, looking for the WIM
for /f "skip=8 tokens=3" %%A in (x:\Output.txt) do (if exist %%A:\Install.swm set ImagePath=%%A:\)
@echo.
set ImagePath 

diskpart /s X:\Windows\System32\diskpart.txt

call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

DISM /Apply-Image /ImageFile:%ImagePath%install.swm /SWMFile:%ImagePath%install*.swm /Index:1 /ApplyDir:W:\

W:\Windows\System32\bcdboot W:\Windows /s S:

md R:\Recovery\WindowsRE
xcopy /h W:\Windows\System32\Recovery\Winre.wim R:\Recovery\WindowsRE\
dism /export-image /sourceimagefile:%ImagePath%install.swm /SWMFile:%ImagePath%install* /SourceIndex:1 /DestinationImageFile:R:\install.wim

W:\Windows\System32\reagentc /Setosimage /path R: /target W:\Windows
W:\Windows\System32\Reagentc /Setreimage /Path R:\Recovery\WindowsRE /Target W:\Windows
W:\Windows\System32\Reagentc /Info /Target W:\Windows



WPEUtil reboot
