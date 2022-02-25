# Get PSSesion
Get-PSSession | Remove-PSSession

# Imports the Server names
$VSphereServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\VMServers.csv"

# Import Modue vmware viautomation core 
Import-Module vmware.vimautomation.core

# Connect to the VMWare server and pulls back the snapsots into a grid-view
Connect-VIServer $VSphereServerImport.Server
$SnapShotList = Get-VM | Get-SnapShot | Select Created, VM, Name, Description, SizeGB
$SnapShotCount = $SnapShotList | Measure
Write-Host "Snapshot Count = " $SnapShotCount.count
$SnapShotList | Sort-Object -Property VM | Out-GridView -Title "VMWare Snapshot List"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
