# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

# AD User filter for all users
$ADUserFilter = "*"


### Remove # from Set-AccountPassword Line to enable Password Reset ###
### Please add the # back before closing the script to reduce the risk of accidently running ###
### If the line has the # the script will only show the users who would be affected ###

$ADUsers = Get-ADUser -SearchBase $OU.DistinguishedName -Filter $ADUserFilter

foreach ($ADUser in $ADUsers)
    {
    Add-Type -AssemblyName System.Web
    $Password = [System.Web.Security.Membership]::GeneratePassword(8,2)
    Write-Host $ADUser.Name $Password
    Set-ADAccountPassword -Identity $ADUser -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
    }

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
