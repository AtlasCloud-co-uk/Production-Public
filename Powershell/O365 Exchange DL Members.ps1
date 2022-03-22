# Connect to Exchange
Connect-ExchangeOnline -ShowBanner:$false

# Get Exchange DL Groups
$DLGroupListSelect = Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress | Out-GridView -Title "Select Distribution List and Click OK" -PassThru
$DLGroupListSelect

# Get Exchange DL Group Members
Get-DistributionGroupMember -Identity $DLGroupListSelect.DisplayName | sort-object DisplayName | Select-Object DisplayName,PrimarySmtpAddress,Manager | Format-Table 

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
