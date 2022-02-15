# Obtain Domain Controller List 
$DCList = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()

# Check each Domain provided by the $DC variable and display output. 
foreach ($DC in $DCList.DomainControllers)
    {
    $DC.Name
    Get-WinEvent -ComputerName $DC.Name -LogName Security -FilterXPath "*[System[EventID=4740 and TimeCreated[timediff(@SystemTime) <= 36000000]] ]" -ErrorVariable +errs -ErrorAction SilentlyContinue |
    Select-Object @{Name='Lockout Time';Expression={$_.TimeCreated}},@{Name='User Name';Expression={$_.Properties[0].Value}},@{Name='Source Host';Expression={$_.Properties[1].Value}} | ft -AutoSize
   Set-ExecutionPolicy Unrestricted }
<#
Non-Terminating Errors have been silenced and will not display
Non-Terminating Errors output have been added to a appending variable +errs
To display the Non-Terminating Errors type $errs after the script has run.
#>
