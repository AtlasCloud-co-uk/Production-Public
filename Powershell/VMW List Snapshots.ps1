# Get PSSesion
Get-PSSession | Remove-PSSession

# Imports the Server names
$VSphereServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\VMServers.csv"

# Import Modue vmware viautomation core 
Import-Module vmware.vimautomation.core

# Connect to the VMWare server and pulls back the snapsots into a grid-view
Connect-VIServer $VSphereServerImport.Server


# Get Snapshot and Events confirm if there is an event log.
$vmsnapshots = Get-VM | Get-Snapshot
$processed = 0
$results = @()
foreach ($snapshot in $vmsnapshots)
{
    Write-Progress -Activity "Getting snapshot CreatedBy info" -PercentComplete (($processed/$vmsnapshots.Length)*100)
    $processed = $processed + 1
    $snapevent = Get-VIEvent -Entity $snapshot.VM -Types Info -Finish $snapshot.Created.AddMinutes(1) -MaxSamples 3 | Where-Object {$_.FullFormattedMessage -imatch 'Task: Create virtual machine snapshot'}

    if ($snapevent -ne $null)
    {
        $user = [string]$snapevent.UserName
        $snapshot | Add-Member CreatedBy $user
    }
    else
    {
        $snapshot | Add-Member CreatedBy '--Unknown--'
    }

  $results = $results + $snapshot

}
Write-Progress -Activity "Sorting" -PercentComplete 0
$results = $results | Sort-Object -Property Created
Write-Progress -Completed -Activity "Sorting" -PercentComplete 100

#Output results to Gridview
$results | Sort-Object VM | Select-Object -Property Created,VM,Name,Description,CreatedBy,SizeGB | Out-GridView -Title "VMWare Snapshot List"


# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
