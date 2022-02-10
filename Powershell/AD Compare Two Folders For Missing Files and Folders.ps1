
<#
    .SYNOPSIS
Compare Two folders for missing files and folders. 
Ability to selected different computers.
Each Path input will be validated.
If a folder is missing, it will not show an extension on the name and the files inside that folder will not be displayed.

#>

#Select First Machine
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect1 = $ComputerList | Out-GridView -Title "Select First Computer Name and Click OK" -OutputMode Single
Write-Host "Computer 1: " $ComputerSelect1.Name

#Enter First Directory Path
$DirectoryPathToScan1 = Read-Host -Prompt "Path"

#Test Directory Path is valid
$TestPath = Invoke-command -ComputerName $ComputerSelect1.Name -scriptBlock {
Test-Path -Path $args[0]
} -ArgumentList $DirectoryPathToScan1
If ($TestPath)
{
Write-Host "Path is Valid" -ForegroundColor Green
}
Else
{
Write-Host "Path does not exist" -ForegroundColor Red
Remove-Variable * -ErrorAction SilentlyContinue
Exit
}

#Select Second Machine
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect2 = $ComputerList | Out-GridView -Title "Select Second Computer Name and Click OK" -OutputMode Single
Write-Host "Computer 2: " $ComputerSelect2.Name

#Enter Second Directory Path
$DirectoryPathToScan2 = Read-Host -Prompt "Path (Or Press Enter to use the same Path)"

# Message Filter Defaul Input if nothing enter
If ([string]::IsNullOrWhiteSpace($DirectoryPathToScan2))

{

$DirectoryPathToScan2 = $DirectoryPathToScan1

}

#Test Directory Path is valid
$TestPath = Invoke-command -ComputerName $ComputerSelect2.Name -scriptBlock {
Test-Path -Path $args[0]
} -ArgumentList $DirectoryPathToScan2
If ($TestPath)
{
Write-Host "Path is Valid" -ForegroundColor Green
}
Else
{
Write-Host "Path does not exist" -ForegroundColor Red
Remove-Variable * -ErrorAction SilentlyContinue
Exit
}
Write-Host ""
Write-host "<= :" $ComputerSelect1.Name -ForegroundColor Yellow
Write-host "=> :" $ComputerSelect2.Name -ForegroundColor Yellow

$FirstFolder = invoke-command -ComputerName $ComputerSelect1.Name -scriptblock {Get-ChildItem -Recurse -path $args[0]}-ArgumentList $DirectoryPathToScan1

$SecondFolder = invoke-command -ComputerName $ComputerSelect2.Name -scriptblock {Get-ChildItem -Recurse -path $args[0]}-ArgumentList $DirectoryPathToScan2

$Compare1 = Compare-Object -ReferenceObject $FirstFolder -DifferenceObject $SecondFolder -Property Name | Select-Object -property *
$Compare1


Remove-Variable * -ErrorAction SilentlyContinue
Added test comments
