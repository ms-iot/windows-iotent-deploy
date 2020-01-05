#Enables IoT Specific policies. Uncomment and needed policies. Each policy has a description of what is does and the value being set.
#The commands are disabled by default. Uncomment the commands to enable policies as needed.

Push-Location -Path $PSScriptRoot
$payload = $PSScriptRoot

#Set Windows Defender policies. The policies set are:
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#CheckForSignaturesBeforeRunningScan
#DWORD:0
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#AvgCPULoadFactor
#DWORD:5
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#DisableCatchupFullScan
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#DisableCatchupQuickScan
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#DisableRestorePoint
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#MissedScheduledScanCountBeforeCatchup
#DWORD:20
#
#3Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#ScanParameters
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Scan
#ScheduleDay
#DWORD:8
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#ASSignatureDue
#DWORD:30
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#AVSignatureDue
#DWORD:30
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#DisableScanOnUpdate
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#DisableUpdateOnStartupWithoutEngine
#DWORD:1
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#ScheduleDay
#DWORD:8
#
#Computer
#SOFTWARE\Policies\Microsoft\Windows Defender\Signature Updates
#SignatureUpdateCatchupInterval
#DWORD:30

#Start-Process -FilePath "$payload\LGPO\LGPO.exe" -ArgumentList "/m $payload\Policies\DefenderSettings.pol" -WindowStyle Hidden -Wait

#Set Delivery Optimization policies. The policies set are:
#Computer
#SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization
#DODownloadMode
#DWORD:0

#Start-Process -FilePath "$payload\LGPO\LGPO.exe" -ArgumentList "/m $payload\Policies\DeliveryOptimization.pol" -WindowStyle Hidden -Wait

#Set Smart Screen policies. The policies set are:
#Computer
#Software\Policies\Microsoft\Windows\System
#EnableSmartScreen
#DWORD:0

#Start-Process -FilePath "$payload\LGPO\LGPO.exe" -ArgumentList "/m $payload\Policies\DisableSmartScreen.pol" -WindowStyle Hidden -Wait

#Set Windows Updates notification level to disabled
#Computer
#Software\Policies\Microsoft\Windows\WindowsUpdate
#SetUpdateNotificationLevel
#DWORD:1

#Computer
#Software\Policies\Microsoft\Windows\WindowsUpdate
#UpdateNotificationLevel
#DWORD:2

#Start-Process -FilePath "$payload\LGPO\LGPO.exe" -ArgumentList "/m $payload\Policies\SetUpdateNotificationLevel.pol" -WindowStyle Hidden -Wait

Pop-Location
