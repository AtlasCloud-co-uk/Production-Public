# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single
Write-Host "Computer: " $ComputerSelect.Name

# List NTFS Folder Permissions on Shared Folders

$Output = Get-LHSsharedFolderNTFSPermission -ComputerName $ComputerSelect.Name -SharePermission -ErrorAction SilentlyContinue

# Display Output in Grid-View
$Output | Out-GridView -Title "Share Permissions"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
