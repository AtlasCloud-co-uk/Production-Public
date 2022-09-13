#############################################################################
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

# Create a table

$tbl = New-Object System.Data.DataTable "Data"
$col1 = New-Object System.Data.DataColumn AccountSkuId
$col2 = New-Object System.Data.DataColumn DisplayName
$col3 = New-Object System.Data.DataColumn EmailAddress
$col4 = New-Object System.Data.DataColumn Licensed
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)
$tbl.Columns.Add($col3)
$tbl.Columns.Add($col4)

# Connect to AD Service
Connect-MsolService

# Get Sevice Plan List
$ServicePlanSelectList = Get-MsolAccountSku | Out-GridView -Title "Service Plan List" -PassThru


# Gets the information and outputs to Gridview
$Output = 
foreach ($ServicePlan in $ServicePlanSelectList) {
    $GetUsers = Get-MsolUser | Where-Object {($_.licenses).AccountSkuId -match $ServicePlan.AccountSkuId}
        foreach ($GetUser in $GetUsers) {

        $row = $tbl.NewRow()
            $row.AccountSkuId = $ServicePlan.AccountSkuId
            $row.DisplayName = $GetUser.DisplayName
            $row.EmailAddress = $GetUser.UserPrincipalName
            $row.Licensed = $GetUser.isLicensed
        $tbl.Rows.Add($row)                  
    }  
}

$tbl | Out-GridView -Title "Licence List"

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
