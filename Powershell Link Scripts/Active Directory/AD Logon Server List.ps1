# Finds the event logs starting 4624, gets the message information from the event, checks again teh supplied name, then from this list removes duplicate IP enteries, shows the shorted list, next it checks this IPS for Hostnames.

# Create a table

$tbl = New-Object System.Data.DataTable "User Log-On Data"
$col1 = New-Object System.Data.DataColumn Time
$col2 = New-Object System.Data.DataColumn User
$col3 = New-Object System.Data.DataColumn Server
$col4 = New-Object System.Data.DataColumn IP
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)
$tbl.Columns.Add($col3)
$tbl.Columns.Add($col4)


# Obtain user name

$User = Read-Host -Prompt "Name (Example: john.glen)"

# Find DC list from Active Directory
$DCs = Import-Csv -Path "C:\Powershell Scripts\CSV\DCServers.csv"


# Define time for report (default is 1 day)
$startDate = (get-date).AddDays(-1)

# Get Event Logs, Start date and Event ID
$slogonevents = @()
 foreach ($DC in $DCs){
     $slogonevents += Get-Eventlog -LogName Security -ComputerName $DCs.Server -after $startDate | where {$_.eventID -eq 4624 }
 }

# Loops through each event filtered by the User, places the, Time Generated, User name, Server Name and IP address into a table
$loop = 
foreach ($e in $slogonevents) {
if($e.ReplacementStrings[5] -eq $user)
 {
 if (($e.EventID -eq 4624 ) -and ($e.ReplacementStrings[8] -eq 3)){
         $row = $tbl.NewRow()
            $row.Time = $e.TimeGenerated
            $row.User = $e.ReplacementStrings[5]
            $row.Server = $e.ReplacementStrings[11]
            $row.IP = $e.ReplacementStrings[18]
        $tbl.Rows.Add($row)
                      
    }
    
}
}

# Left in encase the Out-GridView is useful for trouble shooting.
#$tbl | out-gridview

# Reduce list down to unique IP
$unique = $tbl | sort IP -Unique

# Clear list of any empty IP address
$empty = $unique | where{$_.IP -notmatch "-"}
$empty

#Check IP for Host Name
foreach ($f in $empty){
[System.Net.Dns]::GetHostByAddress($f.ip).Hostname}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue