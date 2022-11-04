$header = @"
<style>

    h1 {

        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;

    }

    
    h2 {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;

    }

    p {

        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 12px;

    }
    
    
   table {
		font-size: 12px;
		border: 0px; 
		font-family: Arial, Helvetica, sans-serif;
	} 
	
    td {
		padding: 4px;
		margin: 0px;
		border: 0;
	}
	
    th {
        background: #395870;
        background: linear-gradient(#49708f, #293f50);
        color: #fff;
        font-size: 11px;
        text-transform: uppercase;
        padding: 10px 15px;
        vertical-align: middle;
	}

    tbody tr:nth-child(even) {
        background: #f0f0f2;
    }

        #CreationDate {

        font-family: Arial, Helvetica, sans-serif;
        color: #ff3300;
        font-size: 12px;

    }
.RunningStatus {
    color: #008000;
}

.StopStatus {
    color: #ff0000;
}    

</style>

"@


# How many days a machine has been up.
$DaysUp = Read-host -prompt "Type the minimal days the machine has been up"


# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -PassThru
Write-Host "Selected Computer/s: " $ComputerSelect.Name
Write-Host "----------"
Write-Host "Processing Request"

<#
Creates an ArrayList for the Catch $errs in the ForEach.
Otherwise the Catch only outputs the last error.
#>
$errs = New-Object System.Collections.ArrayList($null)

# Search for uptime on Selected Machine/s (non-terminating Error Messages Silenced)
$servers = $ComputerSelect.Name | Sort-Object
$currentdate = Get-Date
$OutputLoop = ForEach($server in $servers){
$BootList = $null
  Try 
    {
    $Bootuptime = (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $server -ErrorVariable +errs -ErrorAction SilentlyContinue).LastBootUpTime 
    $uptime = $currentdate - $Bootuptime
    }

   Catch
    {
    $Errs += ($server + " - " + $_.Exception.Message)
    }

  Finally
    {
    if ($uptime.Days -gt $DaysUp)
   {
   "$server Uptime : $($uptime.Days) Days, $($uptime.Hours) Hours, $($uptime.Minutes) Minutes"
   Clear-Variable uptime -ErrorAction SilentlyContinue
   }
    }
}

# Output results as a HTML Report

$htmlreport1 = $OutputLoop | Convertto-html  -Property @{ l="Uptime of $DaysUp days or greater"; e={ $_ } } -Fragment -PreContent "<h1>Computers</h1>"
$htmlreport2 = $errs | ConvertTo-Html -Property @{ l='Exception Message'; e={ $_ } } -Fragment -PreContent "<h2>Skipped Machines Due to Errors</h2>"
$report = convertto-html -Body "$htmlreport1 $htmlreport2" -Title "ADComputerUpTime" -Head $header -PostContent "<p id='CreationDate'>Creation Date: $(Get-Date -Format dd/MM/yy)</p>"
$report | out-file c:\temp\ADComputerUpTime.html
Invoke-Expression c:\temp\ADComputerUpTime.html

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
