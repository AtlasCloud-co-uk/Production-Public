<#

.SYNOPSIS 
    This script reads the event log "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" from 
    multiple servers and outputs the human-readable results to a CSV.  This data is not filterable in the native 
    Windows Event Viewer.

    Version: November 9, 2016


.DESCRIPTION
    This script reads the event log "Microsoft-Windows-TerminalServices-LocalSessionManager/Operational" from 
    multiple servers and outputs the human-readable results to a CSV.  This data is not filterable in the native 
    Windows Event Viewer.

    NOTE: Despite this log's name, it includes both RDP logins as well as regular console logins too.
    
 #>

# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single
Write-Host "Computer: " $ComputerSelect.Name

# Get Date
$StartTime = Read-Host -Prompt "Date" 

#Get Info from server
    foreach ($Server in $ComputerSelect.Name) {

        $LogFilter = @{
            LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
            ID = 21, 23, 24, 25
            StartTime = $StartTime
            }

        $AllEntries = Get-WinEvent -FilterHashtable $LogFilter -ComputerName $Server

        $AllEntries | Foreach { 
            $entry = [xml]$_.ToXml()
            [array]$Output += New-Object PSObject -Property @{
                TimeCreated = $_.TimeCreated
                User = $entry.Event.UserData.EventXML.User
                IPAddress = $entry.Event.UserData.EventXML.Address
                EventID = $entry.Event.System.EventID
                ServerName = $Server
                }        
            } 

    }

    $FilteredOutput += $Output | Select TimeCreated, User, ServerName, IPAddress, @{Name='Action';Expression={
                if ($_.EventID -eq '21'){"logon"}
                if ($_.EventID -eq '22'){"Shell start"}
                if ($_.EventID -eq '23'){"logoff"}
                if ($_.EventID -eq '24'){"disconnected"}
                if ($_.EventID -eq '25'){"reconnection"}
                }
            }
# Output to CSV
    $Date = (Get-Date -Format s) -replace
     ":", "."
    #$FilePath = "$env:USERPROFILE\Desktop\$Date`_RDP_Report.csv"
    $FilePath = "c:\temp\$Date`_RDP_Report.csv"
    $FilteredOutput | Sort TimeCreated | Export-Csv $FilePath -NoTypeInformation

Write-host "Writing File: $FilePath" -ForegroundColor Cyan
Write-host "Done!" -ForegroundColor Cyan

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue

#End
