# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Select Computer from Gridview
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Multiple
Write-Host "Computer: " $ComputerSelect.Name

# Function to get users
Function Get-LoggedInUser {
 
    [CmdletBinding()]
        param(
            [Parameter(
                Mandatory = $false,
                ValueFromPipeline = $true,
                ValueFromPipelineByPropertyName = $true,
                Position=0
            )]
            [string[]] $ComputerName = $ComputerSelect.Name,
 
 
            [Parameter(
                Mandatory = $false
            )]
            [Alias("SamAccountName")]
            [string]   $UserName
        )
 
    BEGIN {}
 
    PROCESS {
        foreach ($Computer in $ComputerName) {
            try {
                $Computer = $Computer.ToUpper()
                $SessionList = quser /Server:$Computer 2>$null
                if ($SessionList) {
                    $Global:UserInfo = foreach ($Session in ($SessionList | select -Skip 1)) {
                        $Session = $Session.ToString().trim() -replace '\s+', ' ' -replace '>', ''
                        if ($Session.Split(' ')[3] -eq 'Active') {
                            [PSCustomObject]@{
                                ComputerName = $Computer
                                UserName     = $session.Split(' ')[0]
                                SessionName  = $session.Split(' ')[1]
                                SessionID    = $Session.Split(' ')[2]
                                SessionState = $Session.Split(' ')[3]
                                IdleTime     = $Session.Split(' ')[4]
                                LogonTime    = $session.Split(' ')[5, 6, 7] -as [string] -as [datetime]
                            } 
                        } else {
                            [PSCustomObject]@{
                                ComputerName = $Computer
                                UserName     = $session.Split(' ')[0]
                                SessionName  = $null
                                SessionID    = $Session.Split(' ')[1]
                                SessionState = 'Disconnected'
                                IdleTime     = $Session.Split(' ')[3]
                                LogonTime    = $session.Split(' ')[4, 5, 6] -as [string] -as [datetime]
                            }
                        }
                    }
 
                    if ($PSBoundParameters.ContainsKey('Username')) {
                        $UserInfo | Where-Object {$_.UserName -eq $UserName}
                      } else {
                        $UserInfo | Sort-Object LogonTime
                    }
                }
            } catch {
                Write-Error $_.Exception.Message
 
            }
        }
    }
 
    END {}
}
Get-LoggedInUser

# List Disconnected Sessions
$ListSessionsDisconnected = $Global:UserInfo | Where {$_.SessionState -like 'Disconnected'} | Select-Object -Property Username,SessionID

# List Active Sessions
$ListSessionsActive = $Global:UserInfo | Where {$_.SessionState -like 'Active'} | Select-Object -Property Username,SessionID

# List Active RDP Sessions
$listSessionsActiveRDP = $Global:UserInfo | Where {($_.SessionState -like 'Active') -and ($_.SessionName -like '*rdp*') } | Select-Object -Property Username,SessionID,SessionName

# Add Logoff Arguement for server and supplied servername. 
$Contcat = "/server:" + $ComputerSelect.Name 

# Function to supply menu and check if session is avaiable and log off users
function Show-LogOffOptions { try
    {
    $LogOffOptions = @"
    Logoff User/s Options:
    [1] Logoff Disconnected User/s
    [2] Logoff RDP Active User/s
    [3] Logoff All Active User/s
    [4] Logoff All User/s
    [5] Quit

    Type a number and press enter 
"@

    $AskLofOffOptions = Read-Host -Prompt $LogOffOptions
		    switch ($AskLofOffOptions) {
		        "1" { if ($ListSessionsDisconnected.SessionID -eq $Null) {Write-host "No User/s Found `n" -ForegroundColor Red -NoNewline;Show-LogOffOptions}
                        else{ 
                            logoff $ListSessionsDisconnected.SessionID $Contcat }}
                "2" { if ($listSessionsActiveRDP.SessionID -eq $Null) {Write-host "No User/s Found `n" -ForegroundColor Red -NoNewline;Show-LogOffOptions}
                        else{ 
                            logoff $listSessionsActiveRDP.SessionID $Contcat }}
		    	"3" { if ($ListSessionsActive.SessionID -eq $Null) {Write-host "No User/s Found `n" -ForegroundColor Red -NoNewline;Show-LogOffOptions}
                        else{
                        logoff $ListSessionsActive.SessionID $Contcat }}
                "4" { if (($ListSessionsActive.SessionID -eq $Null) -and ($ListSessionsDisconnected.SessionID -eq $Null)) {Write-host "No User/s Found `n" -ForegroundColor Red -NoNewline;Show-LogOffOptions}
                        else{
                        logoff $ListSessionsDisconnected.SessionID $Contcat ; logoff $ListSessionsActive.SessionID $Contcat }}
                "5" { break }

		    	Default {Write-Host "One of the listed numbers was not entered";Show-LogOffOptions}
		    }
        }
 catch {
        Write-host "No User/s Found" -ForegroundColor Red -NoNewline
        
    }
}
Show-LogOffOptions

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
