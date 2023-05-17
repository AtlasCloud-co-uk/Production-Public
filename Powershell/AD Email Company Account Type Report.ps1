# Email Parameters Import
$EmailImport = Import-Csv -Path "C:\Powershell Scripts\CSV\EmailParameters.csv"

# Email Parameters

$Subject = $EmailImport.Subject 
$body = $EmailImport.Body
$emailHost = $EmailImport.Host
$emailFrom = $EmailImport.From
$emailsTo=$EmailImport.To
$emailbody=$body
$attachment1 = $EmailImport.Attchment 

#End of parameters

# Email Script Build

$msg = New-Object System.Net.Mail.MailMessage
$msg.from = ($emailFrom)
$msg.sender = ($emailFrom)
$msg.to.add($emailsTo)
$msg.Subject = $Subject
$msg.Body = $emailbody
$msg.isBodyhtml = $true   

$att = new-object System.Net.Mail.Attachment($attachment1)
$msg.Attachments.add($att)
$smtp = New-Object System.Net.Mail.SmtpClient $emailHost
$smtp.send($msg)
$att.Dispose()

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue