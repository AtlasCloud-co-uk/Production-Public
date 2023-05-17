# Imports the Server names
$VSphereServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\VMServers.csv"

# Connect to the VMWare server and pulls back the snapsots into a grid-view
Connect-VIServer $VSphereServerImport.Server

# Get VM's Names
$VM = Get-Cluster -Name production | Get-VM

# Get Network Adaptor Info
foreach ($VMS in $VM) {

$Nettype = Get-NetworkAdapter -VM $VMS

foreach ($nic in $Nettype) {

"{0} {1} {2}" -f $VMS.Name, $nic.Name, $nic.Type

}

} 

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
