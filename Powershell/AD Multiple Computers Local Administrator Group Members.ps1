
#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Opening 64-bit powershell....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}


write-host "Starting Main script body"

#############################################################################
#End
#############################################################################  

# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Select Computer from Gridview
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Multiple

#
$mutli = foreach($comp in $ComputerSelect){
try{
Invoke-Command -ComputerName $Comp.Name -ScriptBlock { Get-LocalGroupMember Administrators} -ErrorAction Stop
}
catch [System.Management.Automation.Remoting.PSRemotingTransportException]
{
write-host "Server not accessiable $($Comp.name)" -ForegroundColor Cyan
}
catch [System.Management.Automation.RemoteException]
{
write-host "Check Server for Orphan Accounts or ignore if AG or Listner $($Comp.name)" -ForegroundColor Green
}
catch{
Write-Warning $Error[0]
}
}

# Display Group Members in Gridview
$DisplayLocalGroupMembers = $mutli | Select-Object PSComputerName,ObjectClass,Name,PrincipalSource | Out-GridView -Title "Display Group Members"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
