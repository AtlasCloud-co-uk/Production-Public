# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single



$MinimumPathLengthsToShow = Read-Host -Prompt ‘Set this to 260 to find problematic paths in Windows. (Default is 0)’

if ([string]::IsNullOrWhiteSpace($MinimumPathLengthsToShow))

{

$MinimumPathLengthsToShow = ‘0’

}

$WriteResultsToConsole = $true

$filePathsAndLengths = [System.Collections.ArrayList]::new()

$DirectoryPathToScan = Read-Host -Prompt "File Path" 
$TestPath = Invoke-command -ComputerName $ComputerSelect.Name -scriptBlock {
Test-Path -Path $args[0]
} -ArgumentList $DirectoryPathToScan
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


$ListFolderItems = Invoke-Command -ComputerName $ComputerSelect.Name -ScriptBlock {

Get-ChildItem -Path $args[0] -Recurse -Force -ErrorAction SilentlyContinue |
Select-Object -Property FullName, @{Name = "FullNameLength"; Expression = { ($_.FullName.Length) } } |
Sort-Object -Property FullNameLength -Descending 

} -ArgumentList $DirectoryPathToScan

$ComputerSelect.Name
Write-Output "----------"

# Show the list of folder/files per Minimum Path Lengths  
$ListFolderItems | ForEach-Object {

$filePath = $_.FullName
$length = $_.FullNameLength

# If this path is long enough, add it to the results.
if ($length -ge $MinimumPathLengthsToShow)
    {
        [string] $lineOutput = "$length : $filePath"

        if ($WriteResultsToConsole) { Write-Output $lineOutput }

        $filePathsAndLengths.Add($_) > $null
    }
}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue 
