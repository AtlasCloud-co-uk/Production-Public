# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single
Write-Host "Computer Name : " $ComputerSelect.Name

# Gets Service List
$ServiceList = Get-Service -ComputerName $ComputerSelect.Name | Sort-Object
$ServiceSelection = $ServiceList | Out-GridView -Title "Select Service Name and Click OK" -OutputMode Single
Write-Host "Service Name :" $ServiceSelection.Name
Write-Host "Service Display Name :" $ServiceSelection.DisplayName

# Gets PID
$ServicePID = (Get-wmiobject win32_service -ComputerName $ComputerSelect.Name| where {$_.name -eq $ServiceSelection.Name}).processID 
Write-Host "PID Number :" $ServicePID

# Opens a session to run the PID to get start time.
$sess=new-pssession $ComputerSelect.Name

$ProcessStartTime =invoke-command -session $sess -ScriptBlock{ (Get-Process -Id $args[0] ).StartTime} -ArgumentList $ServicePID

Write-Host "Start Time: " $ProcessStartTime

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
