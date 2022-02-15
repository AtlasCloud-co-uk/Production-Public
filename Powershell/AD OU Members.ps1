# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object  | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

# Gets the AD Users as per the OU selected, Added the LastLogOnDate properties, display the Name. Enablesand LastLogOnDate
$ADUsers = Get-ADUser -SearchBase $OU.DistinguishedName -Filter * -Properties LastLogOnDate | Select-Object -Property Name,Enabled,LastLogOnDate

# Display the OU Path
$OU.DistinguishedName
Write-Host "------------"
$ADUsers

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
