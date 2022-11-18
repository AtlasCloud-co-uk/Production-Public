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

$PageTitle = "<h1>Email Only and Sage200 Web Only Users MemberOf Report</h1>"

# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter {(Name -eq 'Email Only Users') -or (Name -eq 'Sage200 Web Only Users')} -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Gets the AD Users as per the OU selected, Added the LastLogOnDate properties, display the Name. Enablesand LastLogOnDate
$ADUsers = foreach ($OUName in $OUList){
Get-ADUser -SearchBase $OUName.DistinguishedName -Filter * -Properties LastLogOnDate,Company,samAccountName,memberof,ExtensionAttribute2 | Where {$_.Enabled -eq 1}  | Select-Object -Property Company,Name,ExtensionAttribute2,LastLogOnDate,@{name="MemberOf";expression={$_.MemberOf -join "; "}}
}

# Display the OU Path
#$OU.DistinguishedName
#Write-Host "------------"
#$ADUsers | Sort-Object -Property Company, Name
$ADUsersHTML = $ADUsers | ConvertTo-Html


# Code to create HTML Report

$Report = ConvertTo-Html -Body "$PageTitle
 $ADUsersHTML <p></p>
  " -Title "Company Status Report" -Head $header -PostContent "<script>
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
$Report | Out-File -FilePath c:\Temp\AD-Email-Only-Users-and-Sage200-Web-Only-Users-MemberOf-Report.html
Invoke-Expression c:\Temp\AD-Email-Only-Users-and-Sage200-Web-Only-Users-MemberOf-Report.html


# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue