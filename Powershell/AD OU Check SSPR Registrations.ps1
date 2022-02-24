# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

# Gets the AD Users as per the OU selected, Added the LastLogOnDate properties, display the Name. Enablesand LastLogOnDate
$ADUsers = Get-ADUser -SearchBase $OU.DistinguishedName -Filter * -Properties SSPRQ,LastLogOnDate | Select-Object -Property Name,Enabled,LastLogOnDate,SSPRQ

# Get the list of user confirm SSPRQ and display Output
$Output = foreach ($ADuser in $ADUsers){
if ($ADUser.ssprq -eq $Null)
{
   Write-Host $ADUser.name $ADUser.Enabled "is NOT registered for SSPR." -ForegroundColor Red
}
else
{
   Write-Host $ADUser.name $ADUser.Enabled "is registered for SSPR." -ForegroundColor Green
}
}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
