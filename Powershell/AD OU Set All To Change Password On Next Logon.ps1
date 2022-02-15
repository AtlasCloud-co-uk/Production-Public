# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

$ADUsers = Get-ADUser -SearchBase $OU.DistinguishedName -Filter * | Where {$_.Enabled -eq 'True'}


foreach ($ADUser in $ADUsers)
    {
    Write-Host $ADUser.Name
    Set-ADUser -Identity $ADUser -ChangePasswordAtLogon:$True
    }

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
