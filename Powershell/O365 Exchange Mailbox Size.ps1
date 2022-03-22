# Connect to Exchange
Connect-ExchangeOnline -ShowBanner:$false

# Get Exchange Mailboxes
$MailboxListSelect = Get-EXOMailbox | Sort-Object DisplayName | Select-Object DisplayName,PrimarySmtpAddress | Out-GridView -Title "Select Mailbox/s and Click OK" -PassThru


# Get Exchange Mailbox Size
$Output = Foreach ($MailboxSelect in $MailboxListSelect)
{
Get-EXOMailboxStatistics $MailboxSelect.DisplayName | sort-object User | Select-Object DisplayName,TotalItemsize
}

# Outout details to GridView
$Output | Sort-Object Displayname | Out-GridView -Title "Mailbox Size List"

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
