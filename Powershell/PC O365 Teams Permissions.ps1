﻿#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Opening 64-bit powershell....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}


write-host "Starting Main script body"

#############################################################################
#End
#############################################################################  

# Connect to AD Service
Connect-MsolService

# Get Tenants List
$TenantsListSelect = Get-MsolPartnerContract | Sort-object Name | Select-Object Name,DefaultDomainName | Out-GridView -Title "Select Partner Site and Click OK" -OutputMode Single

# Connect to Exchange
Connect-ExchangeOnline -DelegatedOrganization $TenantsListSelect.DefaultDomainName -ShowBanner:$false

# Get Unified Groups and Users
$TGroups = Get-UnifiedGroup
foreach ($TGroup in $TGroups)
{
Write-Host ""
$TGroup.DisplayName
Get-UnifiedGroupLinks -Identity $TGroup.DisplayName -LinkType Member | Select-Object Name | ft -AutoSize
}

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue