$OUList = Get-ADGroup -Filter * -Properties Name,DistinguishedName | Select-Object -Property Name,DistinguishedName

$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single
$ADGroupFilter = "*"


$ADGroups = $OU

foreach ($ADGroup in $ADGroups)
    {
    Write-Host $ADGroup.Name
    Write-Host "------------"
    $ADGroupMember = Get-ADGroupMember -Identity $ADGroup.DistinguishedName
    $ADGroupMember.Name
    # Write-Host $ADGroupMember.name -Separator ","
    Write-Host ""
    }
    Clear-Variable ADGroup
    
    Test
