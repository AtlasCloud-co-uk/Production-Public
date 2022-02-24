$UserName = Read-Host "Enter part of the UserName you seek"
$ADUser = Get-ADUser -Properties ssprq -Filter "SamAccountName -like '*$UserName*'"
$SSPRQ = $ADUser.ssprq

if ($SSPRQ -like '*AlterEmail*')
{
   Write-Host $ADUser.name "is registered for SSPR."
}
else
{
   Write-Host $ADUser.name "is NOT registered for SSPR."
}

