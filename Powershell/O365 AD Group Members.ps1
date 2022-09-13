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
$col1 = New-Object System.Data.DataColumn GroupName
$col2 = New-Object System.Data.DataColumn MemberType
$col3 = New-Object System.Data.DataColumn DisplayName
$col4 = New-Object System.Data.DataColumn EmailAddress
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)
$tbl.Columns.Add($col3)
$tbl.Columns.Add($col4)

# Connect to AD Service
Connect-MsolService

# Get Azure AD Groups
$AzGroupListSelect = Get-MsolGroup | Sort-Object DisplayName | Select-Object DisplayName,ObjectId | Out-GridView -Title "Select AD Group/s and Click OK" -PassThru

# Gets the information and outputs to Gridview
$Output = 
foreach ($AzGroupSelect in $AzGroupListSelect) {
    $Groups = Get-MsolGroupMember -GroupObjectID $AzGroupSelect.ObJectID
        foreach ($Group in $Groups) {

        $row = $tbl.NewRow()
            $row.GroupName = $AzGroupSelect.DisplayName
            $row.MemberType = $Group.GroupMemberType
            $row.DisplayName = $Group.DisplayName
            $row.EmailAddress = $Group.EmailAddress
        $tbl.Rows.Add($row)                     
    } 
}

$tbl | Out-GridView -Title "Group List"

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
