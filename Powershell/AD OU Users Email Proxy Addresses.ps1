# Gets a list of OU.
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection.
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

#Gets the AD Users Email Proxy Address as per the OU selected.
$ADUsers = Get-ADUser -SearchBase $OU.DistinguishedName -Filter * -Properties proxyAddresses | ForEach {
    ForEach ($Address in $_.proxyAddresses) {
        [pscustomobject]@{
            User = $_.Name
            ProxyAddress = $Address
        }
    }
}


# Display the OU Path.
$OU.DistinguishedName
Write-Host "------------"

# Displays the AD User Name and Proxy Address. 
$ADUsers

# Clears the Variables, this stops any issue with the variables bring back any previous held information.
Remove-Variable * -ErrorAction SilentlyContinue

