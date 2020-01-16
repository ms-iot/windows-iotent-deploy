#SetupEnvironment will create the directories expected by the build framework and remove the mark of the web from the scripts

New-Item -Path .. -Name Source -ItemType directory
New-Item -Path ..\Source -Name ISO -ItemType directory
New-Item -Path .. -Name Payload -ItemType directory
New-Item -Path ..\Payload -Name Payload -ItemType directory
New-Item -Path .. -Name Mount -ItemType directory
New-Item -Path .. -Name "Language Packs" -ItemType directory
New-Item -Path .. -Name Images -ItemType directory
New-Item -Path .. -Name "Feature on Demand" -ItemType directory
New-Item -Path .. -Name Drivers -ItemType directory
New-Item -Path .. -Name Docs -ItemType directory
New-Item -Path .. -Name "Device Guard" -ItemType directory
New-Item -Path .. -Name Deliverable -ItemType directory
New-Item -Path ..\Deliverable -Name ISO -ItemType directory
New-Item -Path ..\Deliverable -Name USB -ItemType directory
New-Item -Path .. -Name "Cumulative Updates" -ItemType directory

#Remove the mark of the web from the deployment framework files
#Remove the mark of the web from the deployment framework files
Get-Item * -Stream "Zone.Identifier" -ErrorAction SilentlyContinue | ForEach {Unblock-File $_.FileName}





