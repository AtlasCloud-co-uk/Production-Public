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
