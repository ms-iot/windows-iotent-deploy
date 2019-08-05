

$CIPolicyPath=$env:userprofile+"\Desktop\"

$InitialCIPolicy=$CIPolicyPath+"InitialScan.xml"

$CIPolicyBin=$CIPolicyPath+"DeviceGuardPolicy.bin"

$EnforcedCIPolicy=$CIPolicyPath+"EnforcedPolicy.xml"

$EnforcedCIPolicyBin=$CIPolicyPath+"EnforcedDeviceGuardPolicy.bin"

New-CIPolicy -Level PcaCertificate -Fallback Hash -FilePath $InitialCIPolicy -UserPEs 3> CIPolicyLog.txt

ConvertFrom-CIPolicy $InitialCIPolicy $CIPolicyBin

Set-RuleOption -FilePath $InitialCIPolicy -Option 9
Set-RuleOption -FilePath $InitialCIPolicy -Option 10

Copy-Item $InitialCIPolicy $EnforcedCIPolicy

Set-RuleOption -FilePath $EnforcedCIPolicy -Option 3 -Delete

ConvertFrom-CIPolicy $EnforcedCIPolicy $EnforcedCIPolicyBin