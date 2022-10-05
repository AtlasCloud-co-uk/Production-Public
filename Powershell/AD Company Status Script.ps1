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

# Parameters
$DC = Get-ADDomain | Select-Object DistinguishedName
$UniqueCompany = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties Company | Where {$_.Enabled -eq 1} | Sort-Object Company -Unique | Select-Object -Property Company
$UniqueExtensionAttribute = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties extensionAttribute2 | Where {$_.Enabled -eq 1} | Sort-Object extensionAttribute2 -Unique | select-object -property extensionAttribute2 -Unique

# Page Title

$PageTitle = "<h1>Company Status Report</h1>"

# All AD User Count

$ADUsers1 = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * | Select-Object -Property Name,Enabled | measure
$ADUsersHTML1 = "<h2>Total Users: <h4>$($ADUsers1.count)</h4></h2>"

# All AD User Count Enabled

$ADUsers2 = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * | Where {$_.Enabled -eq 1} | Select-Object -Property Name,Enabled | measure
$ADUsersHTML2 = "<h2>Enabled: <h4>$($ADUsers2.count)</h4></h2>"

# All AD User Count Disabled

$ADUsers3 = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * | Where {$_.Enabled -eq 0} | Select-Object -Property Name,Enabled | measure
$ADUsersHTML3 = "<h2>Disabled: <h4>$($ADUsers3.count)</h4></h2>"

# All AD User Count Enabled excluding Atlas Cloud Ltd

$AtlasFilterCount1 = Get-ADUser -Filter "Company -ne 'Atlas Cloud Ltd'" -Properties Company -ErrorAction SilentlyContinue | Where {$_.Enabled -eq 1} | Select Name,Company | measure

# All AD User Count Enabled equal to Atlas Cloud Ltd

$AtlasFilterCount2 = Get-ADUser -Filter "Company -eq 'Atlas Cloud Ltd'" -Properties Company -ErrorAction SilentlyContinue | Where {$_.Enabled -eq 1} | Select Name,Company | measure


# Title Count By Attributes
$AtlasFilterTitle = "<h5> Count By Attributes </h5>"

#######Not Equal to Atls Cloud Ltd##############

# Loop for User ExtensionAttribute2 and Measure not equal to Atlas Cloud Ltd 
$LoopExtensionAttribute1 = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
  $ExtensionAttributecount1 = Get-ADUser -Filter "Company -ne 'Atlas Cloud Ltd'" -Properties Company,extensionAttribute2 -ErrorAction SilentlyContinue | Where {($_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)) -and ($_.Enabled -eq 1)} | measure


# Create new Table with Start Type and Count
$hash1=[ordered]@{"ea21"="$($ExtensionAttribute1.extensionAttribute2)"; "ea2Count1"="$($ExtensionAttributecount1.Count)"}
$obj1 = [pscustomobject]$hash1
$obj1
})


# Get From LoopExtensionAttribute2 and change from Table to HTML Layout
$ExtensionAttributehtmlcode1 = foreach($eachline1 in $LoopExtensionAttribute1){
$AtlasFilterCountCitrixHTML1 = "<h2>$($eachline1.ea21):<pd>$($eachline1.ea2Count1)</pd></h2><p></p>"
$AtlasFilterCountCitrixHTML1
}

# Get total Count of Services 
$TotalServicecountlist1 = foreach($total1 in $LoopExtensionAttribute1){
$extract1 = $total1 | Where {($_.ea21 -ne '')}
$Addtotal1 += [int] $extract1.ea2Count1
$Addtotal1
}
$TotalServicecount1 = $TotalServicecountlist1[-1]

# Match Attribute totals
$AtlasAttributeConfirmTotalMatch1 = if ($($TotalServicecount1) -ne $($AtlasFilterCount1.count)){
"<h4 style='background: Red; color: White;'>$($TotalServicecount1)</h4>" }
else {"<h4>$($TotalServicecount1)</h4>"
}
$AtlasAttributeCountTotalHTML1 = "<h2>Total (excluding blank Attributes if showing): <h4>$($TotalServicecount1)</h4></h2>"

# Match All User totals
$AtlasAllConfirmTotalMatch1 = if ($($TotalServicecount1) -ne $($AtlasFilterCount1.count)){
"<h4 style='background: Red; color: white;'>$($AtlasFilterCount1.count)</h4>" }
else {"<h4>$($AtlasFilterCount1.count)</h4>"
}


# Showing missing users
$AtlasFilterGetMissingUser1 = if ($AtlasAttributeConfirmTotalMatch1 -like '*style*'){
$AtlasFilterGetMissingUserList1 = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties Company,extensionAttribute2  | Where {($_.Enabled -eq 1) -and ($_.extensionAttribute2 -eq $null)} | Sort-Object Company | Select-Object -Property Name,Company,extensionAttribute2
$AtlasFilterGetMissingUserList1
}
$AtlasFilterGetMissingUserHTML1 = $AtlasFilterGetMissingUser1 | ConvertTo-Html

# Hidden extensionAttribute2 Count Layout
$AtlasFilterTableHTML = "$AtlasFilterTitle <p></p>
 $ExtensionAttributehtmlcode1<p></p>
 $AtlasAttributeCountTotalHTML1<p></p>
 $AtlasFilterGetMissingUserHTML1"
 $AtlasFilterTableButton1 = "<h2>Total Users (exc Atlas Cloud Ltd): <h4>$($AtlasAllConfirmTotalMatch1)</h4> </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'> <p>$AtlasFilterTableHTML</p> </div>"


#######Equal to Atlasl Cloud Ltd##############


# Loop for User ExtensionAttribute2 and Measure equal to Atlas Cloud Ltd 
$LoopExtensionAttribute2 = @(foreach($ExtensionAttribute2 in $UniqueExtensionAttribute){
  $ExtensionAttributecount2 = Get-ADUser -Filter "Company -eq 'Atlas Cloud Ltd'" -Properties Company,extensionAttribute2 -ErrorAction SilentlyContinue | Where {($_.extensionAttribute2 -eq $($ExtensionAttribute2.extensionAttribute2)) -and ($_.Enabled -eq 1)} | measure


# Create new Table with Start Type and Count
$hash2=[ordered]@{"ea22"="$($ExtensionAttribute2.extensionAttribute2)"; "ea2Count2"="$($ExtensionAttributecount2.Count)"}
$obj2 = [pscustomobject]$hash2
$obj2
})
#$LoopExtensionAttribute2

# Get From LoopExtensionAttribute2 and change from Table to HTML Layout
$ExtensionAttributehtmlcode2 = foreach($eachline2 in $LoopExtensionAttribute2){
$AtlasFilterCountCitrixHTML2 = "<h2>$($eachline2.ea22):<pd>$($eachline2.ea2Count2)</pd></h2><p></p>"
$AtlasFilterCountCitrixHTML2
}


# Get total Count of Services 
$TotalServicecountlist2 = foreach($total2 in $LoopExtensionAttribute2){
$extract2 = $total2 | Where {($_.ea22 -ne '')}
$Addtotal2 += [int] $extract2.ea2Count2
$Addtotal2
}
$TotalServicecount2 = $TotalServicecountlist2[-1]


# Match Attribute totals
$AtlasAttributeConfirmTotalMatch2 = if ($($TotalServicecount2) -ne $($AtlasFilterCount2.count)){
"<h4 style='background: Red; color: White;'>$($TotalServicecount2)</h4>" }
else {"<h4>$($TotalServicecount2)</h4>"
}
$AtlasAttributeCountTotalHTML2 = "<h2>Total (excluding blank Attributes if showing): <h4>$($AtlasAttributeConfirmTotalMatch2)</h4></h2>"

# Match All User totals
$AtlasAllConfirmTotalMatch2 = if ($($TotalServicecount2) -ne $($AtlasFilterCount2.count)){
"<h4 style='background: Red; color: white;'>$($AtlasFilterCount2.count)</h4>" }
else {"<h4 >$($AtlasFilterCount2.count)</h4>"
}

# Showing missing users

$AtlasFilterGetMissingUser2 = if ($AtlasAttributeConfirmTotalMatch2 -like '*style*'){
$AtlasFilterGetMissingUserList2 = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties Company,extensionAttribute2  | Where {($_.Enabled -eq 1) -and ($_.extensionAttribute2 -eq $null)} | Sort-Object Company | Select-Object -Property Name,Company,extensionAttribute2
$AtlasFilterGetMissingUserList2
}
$AtlasFilterGetMissingUserHTML2 = $AtlasFilterGetMissingUser2 | ConvertTo-Html

# Hidden extensionAttribute2 Count Layout

$AtlasFilterTableHTML = "$AtlasFilterTitle <p></p>
 $ExtensionAttributehtmlcode2<p></p>
 $AtlasAttributeCountTotalHTML2 <p></p>
 $AtlasFilterGetMissingUserHTML2"
 $AtlasFilterTableButton2 = "<h2>Total Users (exc Atlas Cloud Ltd): <h4>$($AtlasAllConfirmTotalMatch2)</h4>  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'> <p>$AtlasFilterTableHTML</p> </div>"
 
# Login Days Count

$Login30days = Get-ADUser -Filter {Enabled -eq $TRUE} -SearchBase $DC.DistinguishedName -Properties Name,SamAccountName,LastLogonDate | Where {($_.LastLogonDate -gt (Get-Date).AddDays(-30)) -and ($_.LastLogonDate -ne $NULL)} | Sort | Select Name,SamAccountName,LastLogonDate | measure
$Login30daysHTML = "<h2>Enabled Users logged in within the last 30 days: <h4>$($Login30days.Count)</h4>"
$Login60days = Get-ADUser -Filter {Enabled -eq $TRUE} -SearchBase $DC.DistinguishedName -Properties Name,SamAccountName,LastLogonDate | Where {($_.LastLogonDate -lt (Get-Date).AddDays(-30)) -and ($_.LastLogonDate -gt (Get-Date).AddDays(-60)) -and ($_.LastLogonDate -ne $NULL)} | Sort | Select Name,SamAccountName,LastLogonDate | measure
$Login60daysHTML = "<h2>Enabled Users logged in within the last 60 days: <h4>$($Login60days.Count)</h4>"
$Login90days = Get-ADUser -Filter {Enabled -eq $TRUE} -SearchBase $DC.DistinguishedName -Properties Name,SamAccountName,LastLogonDate | Where {($_.LastLogonDate -lt (Get-Date).AddDays(-60)) -and ($_.LastLogonDate -gt (Get-Date).AddDays(-90)) -and ($_.LastLogonDate -ne $NULL)} | Sort | Select Name,SamAccountName,LastLogonDate | measure
$Login90daysHTML = "<h2>Enabled Users logged in within the last 90 days: <h4>$($Login90days.Count)</h4>"

# User accounts by Company and Log In Days

$ListCompany = @(Foreach ($UniqueCompanys2 in $UniqueCompany){
$CompanyNumbers2 = Get-ADUser -Filter "Company -eq '$($UniqueCompanys2.Company)'" -Properties Company -ErrorAction SilentlyContinue | Where {$_.Enabled -eq 1} | Select Name,Company | measure
$Login30days2 = Get-ADUser -Filter "Company -eq '$($UniqueCompanys2.Company)'" -Properties Name,SamAccountName,LastLogonDate,Company | Where {($_.Enabled -eq 1 -and $_.LastLogonDate -gt (Get-Date).AddDays(-30))} | Sort | Select Name,SamAccountName,LastLogonDate | measure
$Login60days2 = Get-ADUser -Filter "Company -eq '$($UniqueCompanys2.Company)'" -Properties Name,SamAccountName,LastLogonDate,Company | Where {($_.Enabled -eq 1 -and $_.LastLogonDate -lt (Get-Date).AddDays(-30)) -and ($_.LastLogonDate -gt (Get-Date).AddDays(-60))} | Sort | Select Name,SamAccountName,LastLogonDate | measure
$Login90days2 = Get-ADUser -Filter "Company -eq '$($UniqueCompanys2.Company)'" -Properties Name,SamAccountName,LastLogonDate,Company | Where {($_.Enabled -eq 1 -and $_.LastLogonDate -lt (Get-Date).AddDays(-60)) -and ($_.LastLogonDate -gt (Get-Date).AddDays(-90))} | Sort | Select Name,SamAccountName,LastLogonDate | measure

$hash3=[ordered]@{"Company"="$($UniqueCompanys2.Company)"; "Licence Count"="$($CompanyNumbers2.Count)"; "30 Days"="$($Login30days2.Count)"; "60 days"="$($Login60days2.Count)"; "90 Days"="$($Login90days2.Count)"}
$obj3 = [pscustomobject]$hash3
$obj3
})
$ListCompanyHTML = $Listcompany | ConvertTo-Html
$ListCompanyButton = "<h2>List Logged In by Company:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p class='a'>*Table automatically exported to Company30-90logon.csv in the same location as shown in the URL</p> <p>$ListCompanyHTML</p> </div>"
$ListcompanyCSV = $Listcompany | Export-Csv -Path .\Company30-90logon.csv 

#Company Users Not logged on for over 90days and Null per Company

$ListCompanyOver90days = @(Foreach ($UniqueCompanys in $UniqueCompany){
$LoginOver90days = Get-ADUser -Filter "Company -eq '$($UniqueCompanys.Company)'" -Properties Name,SamAccountName,LastLogonDate,Company,extensionAttribute2 | Where {($_.Enabled -eq 1 -and $_.LastLogonDate -lt (Get-Date).AddDays(-90)) -and ($_.lastlogontimestamp -like "*")} | Sort | Select-object Company,Name,SamAccountName,LastLogonDate,extensionAttribute2
$LoginOver90days
})
$ListCompanyOver90daysCount = $ListCompanyOver90days | Measure
$ListCompanyOver90daysHTML = $ListCompanyOver90days| ConvertTo-Html
$ListCompanyOver90daysButton = "<h2>List Enabled Users by Company that have either:<br>Never Logged in or Not Logged in for Over 90 days: <h4>$($ListCompanyOver90daysCount.Count)</h4> </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'> <p class='a'>*Table automatically exported to CompanyOver90days.csv in the same location as shown in the URL</p><p>$ListCompanyOver90daysHTML</p> </div>"




# Code to create HTML Report

$Report = ConvertTo-Html -Body "$PageTitle
 $ADUsersHTML1 <p></p>
 $ADUsersHTML2 <p></p>
 $ADUsersHTML3 <p></p>
 $AtlasFilterTableButton1 <p></p>
 $AtlasFilterTableButton2 <p></p>
 $Login30daysHTML <p></p>
 $Login60daysHTML <p></p>
 $Login90daysHTML <p></p>
 $ListCompanyOver90daysButton<p></p>
 $ListCompanyButton
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
$Report | Out-File -FilePath .\AD-Company-Status-Report.html
Invoke-Expression .\AD-Company-Status-Report.html

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
