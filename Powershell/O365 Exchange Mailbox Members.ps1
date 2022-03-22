# Connect to Exchange
Connect-ExchangeOnline -ShowBanner:$false

# Get Exchange Mailboxes
$MailboxListSelect = Get-EXOMailbox | Sort-Object DisplayName | Select-Object DisplayName,PrimarySmtpAddress | Out-GridView -Title "Select Mailbox List and Click OK" -OutputMode Single
$MailboxListSelect

# Get Exchange Mailboxe Member
Get-EXOMailboxPermission $MailboxListSelect.DisplayName | sort-object User | Format-Table

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
