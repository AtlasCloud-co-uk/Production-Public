# Computer name input
Write-Host "-Mandatory-" -ForegroundColor Red
$ComputerFilter =  Read-Host -Prompt "Computer Name (Example: adxadk01)"


$Output=@()

# Computer Name Check
$Computers = Get-ADComputer -Filter * | where {($_.Name -like $ComputerFilter) -and ($_.Name -notlike "*xx")}

# Log Name Input
Write-Host "-Mandatory-" -ForegroundColor Red
$LogName = Read-Host -Prompt "Log Name (Example: Application)"

# Event ID Input
Write-Host "-If Required-" -ForegroundColor Green
$EventID = Read-Host -Prompt "Event ID (Example: 3012)"

# Message Filter Input
Write-Host "-If Required-" -ForegroundColor Green
$MessageFilter = Read-Host -Prompt "Message Filter (Example: *Citrix*)"

# Message Filter Defaul Input if nothing enter
If ([string]::IsNullOrWhiteSpace($MessageFilter))

{

$MessageFilter = ‘*’

}


# Different FilterPath depending on Input 
If ($EventID -eq "")
{$FilterPath = "*"}
Else
{$FilterPath = "*[System[EventID=" + $EventID + " ] ]"}


# Combined information to get data
foreach ($Computer in $Computers)
    {
    # Write-Host $Computer.name
    $Output += Get-WinEvent -ComputerName $Computer.Name -LogName $LogName -FilterXPath $FilterPath | Where {$_.Message -like $MessageFilter} | Select-Object TimeCreated, MachineName, ID, LevelDisplayname, Message
    }
    $Output | Sort-Object TimeCreated | Out-GridView -Title "Select Event List"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
