# Connect to AD Service
Connect-MsolService

# Get Tenants List
$TenantsListSelect = Get-MsolPartnerContract | Sort-object Name | Select-Object Name,DefaultDomainName | Out-GridView -Title "Select Partner Site and Click OK" -OutputMode Single

# Connect to Exchange
Connect-ExchangeOnline -DelegatedOrganization $TenantsListSelect.DefaultDomainName -ShowBanner:$false

# Get Exchange DL Groups
$DLGroupListSelect = Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress | Out-GridView -Title "Select Distripution List and Click OK" -PassThru
$DLGroupListSelect

# Get Exchange DL Group Members
Get-DistributionGroupMember -Identity $DLGroupListSelect.DisplayName | sort-object DisplayName | Select-Object DisplayName,PrimarySmtpAddress,Manager | Format-Table 

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
