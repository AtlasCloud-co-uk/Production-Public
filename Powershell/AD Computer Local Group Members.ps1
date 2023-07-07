# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Select Computer from Gridview
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single


# Get Local Groups
$LocalGroups = Invoke-Command -ComputerName $ComputerSelect.Name -ScriptBlock { Get-LocalGroup }

# Select Local Group from Gridview
$SelectLocalGroup = $LocalGroups | Out-GridView -Title "Select Group Name and Click OK" -OutputMode Single

# Get Just Group Name
$SelectJustname = $SelectLocalGroup.Name

# Select Local Group Members from Selected
$LocalGroupMembers = Invoke-Command -ComputerName $ComputerSelect.Name -ScriptBlock { Get-LocalGroupMember $using:SelectJustname}

# Display Group Members in Gridview
$DisplayLocalGroupMembers = $LocalGroupMembers | Out-GridView -Title "Display Group Members"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue