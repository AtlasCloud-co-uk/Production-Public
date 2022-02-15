# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single
Write-Host "Computer Name: " $ComputerSelect.Name

# Gets a list of Event Log Names
$LogNameList = Get-EventLog -LogName * -ComputerName $ComputerSelect.Name | Sort-Object | Select-Object -Property Log
$LogSelect = $LogNameList | Out-GridView -Title "Select Log Name and Click OK" -OutputMode Single
Write-Host "Log Name: " $LogSelect.Log

# Gets a list of the Event ID's
$EventNameList = Get-WinEvent -LogName $LogSelect.Log -ComputerName $ComputerSelect.Name | Sort-Object | Select-Object -Property ProviderName,ID,Message
$EventNameSelect = $EventNameList | Out-GridView -Title "Select Event Number and Click OK" -OutputMode Single
Write-Host "Event : " $EventNameSelect.Id

# Combinds the above and outputs
$GetLogEvent = Get-WinEvent -LogName Application -ComputerName $ComputerSelect.Name | Where-Object ID -eq $EventNameSelect.Id
$GetLogEvent

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
