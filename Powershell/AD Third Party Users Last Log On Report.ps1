
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

# HTML Code

$header = "

<style>

    body {
        padding: 0em 1em;
        }

    h1 {
        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 28px;
       } 


    h2 {
        font-family: Arial, Helvetica, sans-serif;
        color: #000099;
        font-size: 16px;
        display:inline;
        }

    h3 {
        font-family: Arial, Helvetica, sans-serif;
        color: #FFFFFF;
        font-size: 24px;
        display:inline;
        }
    
    h4 {
        font-family: Arial, Helvetica, sans-serif;
        color: #008000;
        font-size: 16px;
        display:inline;
        }

    h5 {
        font-family: Arial, Helvetica, sans-serif;
        color: #e68a00;
        font-size: 16px;
        display:inline;
        }

    p.a {
        font-style: italic;
        font-size: 12px;
        }

    pd {
        font-family: Arial, Helvetica, sans-serif;
        color: #008000;
        font-size: 16px;
        display:inline;
        padding: 5px
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

    button {
        line-height: 1.5em;
        height: 1.5em;
        width: 1.5em;
        border-radius: 50%;
        display: inline;
        position: inline;
        }

    /* Style the button that is used to open and close the collapsible content */

    .collapsible {
        background-color: #008000;
        color: #444;
        padding: 0px 0px;
        border: none;
        outline: none;
        font-size: 15px;
        }

    /* Add a background color to the button if it is clicked on (add the .active class with JS), and when you move the mouse over it (hover) */

    .active, .collapsible:hover {
        background-color: #66CDAA;
        }

    /* Style the collapsible content. Note: hidden by default */

    .content {
        padding: 0 18px;
        display: none;
        overflow: hidden;
        }

</style>

”

# Page Title

$PageTitle = "<h1>Third Party Accounts</h1>"
$Note = "<p class='a'>This information provides how long since the users has last logged on and if at all.</p>"

# Import the Specific OU
$ADOU = Import-Csv -Path "C:\Powershell Scripts\CSV\ThirdPartyUsersOu.csv" 

# Get Date
$Date = Get-Date

# Get AD Users from Specific OU where Last Logon Is Not Empty
$ADUsers = Get-ADUser -SearchBase $ADOU.OU -filter * -Properties "LastLogonDate" | Where {$_.LastLogonDate -ne $null} | select name, LastLogonDate

# Get difference between last log-on and todays date.
$Difference = foreach ($ADUser in $ADUsers)
 {$days = if ($ADUser.LastLogonDate) {New-TimeSpan -Start $ADUser.LastLogonDate -end $Date}
 $object = New-Object PSObject -Property @{
                Name = $ADUser.Name
                Days = $days.Days 
                }
                $object
 }

# Display User and Last Log On Date in Days in Descending Order
$ReportDiff = $Difference | Sort-Object -Property Days -Descending

$ReportDiffConHTML = $ReportDiff | ConvertTo-Html

$ReportDiffHTML ="<h2>User/s last logged on.</h2><p>$ReportDiffConHTML</p>"

# Get AD Users from Specific OU where Last Logon Is Empty
$ADUsersEmpty = Get-ADUser -SearchBase $ADOU.OU -filter * -Properties "LastLogonDate","Created" | Where {$_.LastLogonDate -eq $null} | select name, Created

$ADUsersEmptyConHTML = $ADUsersEmpty | ConvertTo-Html

$ADUsersEmptyHTML = "<h2>User/s has never logged-on.</h2><p>$ADUsersEmptyConHTML</p>"

# Convert to CSV
$Report = ConvertTo-Html -Body "$PageTitle
 $ReportDiffHTML<p></p>
 $ADUsersEmptyHTML<p></p>
    " -Title "Third Party List" -Head $header -PostContent "<script>
  var coll = document.getElementsByClassName('collapsible');
        var i;
        
        for (i = 0; i < coll.length; i++) {
          coll[i].addEventListener('click', function() {
            this.classList.toggle('active');
            var content = this.nextElementSibling;
            if (content.style.display === 'block') {
              content.style.display = 'none';
            } else {
              content.style.display = 'block';
            }
          });
        }
        </script><p id='CreationDate'>Creation Date: $(Get-Date)</p>"
$Report | Out-File -FilePath c:\temp\Third-Party-Report.html
Invoke-Expression c:\temp\Third-Party-Report.html



#Clears the Variables, this stops any issue with the variables bring back any previous held information
#Remove-Variable * -ErrorAction SilentlyContinue
