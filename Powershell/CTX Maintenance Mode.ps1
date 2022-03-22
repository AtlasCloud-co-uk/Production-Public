# Load Citrix PowerShell modules
Asnp Citrix.*

# Load Citirx Broker
$CitrixServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\CitrixBroker.csv"

#Check VMs show if in Maintetance mode and powered on.
Get-BrokerDesktop -AdminAddress $CitrixServerImport.server -InMaintenanceMode $true| Where-Object { $_.PowerState -eq "On"} | Select-Object HostedMachineName,RegistrationState,PowerState

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue