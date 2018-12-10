diskpart /s X:\Windows\System32\diskpart.txt

call powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

DISM /Apply-Image /ImageFile:R:\install.wim /Index:1 /ApplyDir:W:\

Bcdboot W:\Windows /s S:

WPEUtil reboot
