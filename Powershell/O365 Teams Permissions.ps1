# Create a table

$tbl = New-Object System.Data.DataTable "Data"
$col1 = New-Object System.Data.DataColumn TeamsName
$col2 = New-Object System.Data.DataColumn UserName
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)


# Connect to Exchange
Connect-ExchangeOnline -ShowBanner:$false

# Get Unified Groups and Users
$TGroups = Get-UnifiedGroup | Sort-Object DisplayName

$Output = foreach ($TGroup in $TGroups)
{
    $TeamMembers = Get-UnifiedGroupLinks -Identity $TGroup.DisplayName -LinkType Member | Sort-Object Name | Select-Object Name
    foreach ($GetUser in $TeamMembers) {

        $row = $tbl.NewRow()
            $row.TeamsName = $TGroup.DisplayName
            $row.UserName = $GetUser.Name
        $tbl.Rows.Add($row)                  
    }  


}

$tbl | Out-GridView -Title "Team Names and Members"

# Close Connection
Get-PSSession | Remove-PSSession

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue

#ft -AutoSize