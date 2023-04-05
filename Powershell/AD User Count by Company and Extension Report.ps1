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
$UniqueCompanys = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties Company | Where {$_.Enabled -eq 1} | Sort-Object Company -Unique | Select-Object -Property Company
$UniqueExtensionAttribute = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties extensionAttribute2 | Where {$_.Enabled -eq 1} | Sort-Object extensionAttribute2 -Unique | select-object -property extensionAttribute2 -Unique


## Create Table to show the total of each ExtensionAtrribute2 Type for each client ##

# Create Table for total of each ExtensionAtrribute2 Type for each client count
$CompanyExtensionAttribute2Count = foreach ($UniqueCompanys1 in $UniqueCompanys) {foreach ($UniqueExtensionAttribute1 in $UniqueExtensionAttribute) {
$CompExtATT2Count1 = Get-ADUser -filter "Company -like '$($UniqueCompanys1.Company)'"  -Properties Company,extensionAttribute2 -ErrorAction SilentlyContinue | Where {($_.Enabled -eq 1) -and ($_.extensionAttribute2 -eq $($UniqueExtensionAttribute1.extensionAttribute2))} | Sort-Object | Select-Object -property Name,Company,extensionAttribute2 | Measure

# Create new Table with Start Type and Count
$hash1=[ordered]@{"Company"="$($UniqueCompanys1.Company)"; "Type"="$($UniqueExtensionAttribute1.extensionAttribute2)"; "Count"="$($CompExtATT2Count1.Count)"}
$obj1 = [pscustomobject]$hash1
$obj1
}
}

# Removes where 0 count for each attribute count per company
$CompanyExtensionAttribute2CountExcludingZero = foreach ($CompanyExtensionAttribute2Count1 in $CompanyExtensionAttribute2Count) {$CompanyExtensionAttribute2Count1 | where {$_.count -ne 0}}

# Count
$CompExtATT2Count2 = $CompanyExtensionAttribute2CountExcludingZero | Measure-Object -Property count -sum

# Sum count
$CompExtATT2Count3 = $CompExtATT2Count2.Sum

##-----##

## All User List ##

# List all Users with Company and ExtenstionAttribute2
$CompanyExtensionAttribute2 = foreach ($UniqueCompanys2 in $UniqueCompanys) {foreach ($UniqueExtensionAttribute2 in $UniqueExtensionAttribute) {
Get-ADUser -filter "Company -like '$($UniqueCompanys2.Company)'"  -Properties Company,extensionAttribute2 -ErrorAction SilentlyContinue | Where {($_.Enabled -eq 1) -and ($_.extensionAttribute2 -eq $($UniqueExtensionAttribute2.extensionAttribute2))} | Sort-Object -Property Company,Name | Select-Object -property Name,Company,extensionAttribute2
}
}

# Title For User List
$AtlasFilterTitle = "<h5> Count By Attributes </h5>"

##-----##

########## RDS User List and Count #########

# Gets a list of Groups
$GroupListRDS = Get-ADGroup -Filter * -Properties Name,DistinguishedName | Where {($_.Name -like "*_RDS_Users")} | Sort-Object  | Select-Object -Property Name,DistinguishedName


# Gets the AD Group members SamAccountName as per the Group selected
$UserListRDS = foreach ($GroupRDS in $GroupListRDS){
    $ListUsersRDS = Get-ADGroupMember -identity "$($GroupRDS.Name)" | Select-Object -Property SamAccountName
        foreach ($ADUserRDS in $ListUsersRDS){
            $ListRDS = Get-Aduser -Identity $ADUserRDS.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,name,SamAccountName,company
            $ListRDS           
            }
}

# Remove Duplicates (Encase user is in more then one RDS Security Group)
$UserListRDSUnique = $UserListRDS | Sort-Object extensionAttribute2,Company | Select-Object -Property extensionAttribute2,name,SAMAccountName,Company -Unique

# Count each extentionAttribute2
$CountRDS = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetRDS = $UserListRDSUnique | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsRDS = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetRDS.count)</pd></h2<p></p>"
$AddDetailsRDS
})

# Total Count of RDS
$TotalCountRDS = $UserListRDSUnique | Measure

##-----##

########## Citrix User List and Count #########

# Gets a list of Groups
$GroupListXA = Get-ADGroup -Filter * -Properties Name,DistinguishedName | Where {$_.Name -like "*_XA_Users"} | Sort-Object  | Select-Object -Property Name,DistinguishedName


# Gets the AD Group members SamAccoountName as per the Group selected
$UserListXA = foreach ($GroupXA in $GroupListXA){
    $ListUsersXA = Get-ADGroupMember -identity $GroupXA.Name | Select-Object -Property SamAccountName
        foreach ($ADUserXA in $ListUsersXA){
            $ListXA = Get-Aduser -Identity $ADUserXA.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,Name,SamAccountName,company
            $ListXA           
            }
}

# Remove Duplicates (Encase user is in more then one Citrix Security Group)
$UserListXAUnique = $UserListXA | Sort-Object extensionAttribute2,Company | Select-Object -Property extensionAttribute2,name,SAMAccountName,Company -Unique

# Count each extentionAttribute2

$CountXA = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetXA = $UserListXAUnique | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsXA = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetXA.count)</pd></h2<p></p>"
$AddDetailsXA
})

# Total Count of XA
$TotalCountXA = $UserListXAUnique | Measure

##-----###

########## Not in XA or RDS User List and Count #########

# Combine the RDS and Citrix List
$UserListOT = $UserListRDSUnique + $UserListXAUnique

# Count Combined Users
$UserListCountOT = $UserListOT | measure

# Get List of AD Users
$OUlistOT = get-aduser -filter {Enabled -eq $True} -SearchBase $DC.DistinguishedName | Get-AdUser | Select-Object -Property SamAccountName

# Compare the combined RDS and Citrix users againest the AD User list, output list of users not in a Citrixor RDS group
$ListCompareOT = (compare-object -ReferenceObject $UserListOT -DifferenceObject $OUListOT -Property 'SamAccountName' | ?{$_.sideindicator -eq '=>'}) 

# Get AD User Details
$GetCompareUserOT = foreach ($NameOT in $ListCompareOT){
$ADNameOU = Get-Aduser -Identity $NameOT.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,name,SamAccountName,company
            $ADNameOU
            }
          

# Count each extentionAttribute2

$ListCountOT = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetOT = $GetCompareUserOT  | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsOT = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetOT.count)</pd></h2<p></p>"
$AddDetailsOT
})

## Compare and Substract for Totals ##

# Compare for duplicates and count
$CompareRDSXACount = compare-Object -ReferenceObject $UserListRDSUnique.SamAccountName -DifferenceObject $UserListXAUnique.SamAccountName -IncludeEqual -ExcludeDifferent | Measure

# Compare for duplicates and list users
$CompareRDSXA = compare-Object -ReferenceObject $UserListRDSUnique.SamAccountName -DifferenceObject $UserListXAUnique.SamAccountName -IncludeEqual -ExcludeDifferent

# Add RDS and Citrix Totals
$TotalCountRDSXA = $TotalCountRDS.Count + $TotalCountXA.Count

# Subtract Duplicates from combined RDS and Citrix Total
$TotalRDSXAlessduplicates = $TotalCountRDSXA - $CompareRDSXACount.count

##-----##

########## HTML Values for Report ##########

# Page Title
$PageTitle = "<h1>User Count by Company and Extension Report</h1>"

## User Count Per Attribute and List ##

# Total Users
$CompExtATT2Count3HTML = "<h2>Total Enabled Accounts: <h4>$($CompExtATT2Count3)</h4></h2>"

# List by Company and Account Type Count
$CompanyExtensionAttribute2CountExcludingZeroHTML = $CompanyExtensionAttribute2CountExcludingZero | ConvertTo-Html
$ListCompanyButton1 = "<h2>List by Company and Account Type Count:  </h2><button type='button' class='collapsible'><h3>+</h3></button><div class='content'><p>$CompanyExtensionAttribute2CountExcludingZeroHTML</p> </div>"

# List by Company, User Name and Account Type
$CompanyExtensionAttribute2HTML = $CompanyExtensionAttribute2 | ConvertTo-Html
$ListCompanyButton2 = "<h2>List by Company, User Name and Account Type:  </h2><button type='button' class='collapsible'><h3>+</h3></button><div class='content'><p>$CompanyExtensionAttribute2HTML</p> </div>"

##---##

## RDS Users ##

# User Table RDS into HTML
$UserListRDSHTML = $UserListRDSUnique | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListRDSButton = "<h2>List RDS Users:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListRDSHTML</p> </div>"

# Convert Count to HTML
$TotalCountRDSHTML = $TotalCountRDS.count

# Total RDS User Count
$CountRDSHTML = $CountRDS | ConvertTo-Html
$CountRDSButton = "<h2>Total RDS User Count:<pd>$($TotalCountRDSHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CountRDS</p> </div>"

##---##

## Citrix Users ## 

# User Table XA into HTML
$UserListXAHTML = $UserListXAUnique | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListXAButton = "<h2>List Citrix Users:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListXAHTML</p> </div>"

#
$TotalCountXAHTML = $TotalCountXA.count

# Total Citrix User Count
$CountXAHTML = $CountXA | ConvertTo-Html
$CountXAButton = "<h2>Total Citrix User Count:<pd>$($TotalCountXAHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CountXA</p> </div>"

##---##

## No Access ## 

# User Table OT into HTML
$UserListOTHTML = $GetCompareUserOT | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListOTButton = "<h2>List Users not in a RDS or Citrix Group:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListOTHTML</p> </div>"

# Measure List Comparison
$TotalCountOT = $ListCompareOT | Measure

# Just get Count number
$TotalCountOTHTML = $TotalCountOT.count

# Total Users not in a RDS or Citrix Group Count
$CountOTHTML = $CountOT | ConvertTo-Html
$CountOTButton = "<h2>Total Users not in a RDS or Citrix Group Count:<pd>$($TotalCountOTHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$ListCountOT</p> </div>"


# RDS and Citrix Totals Less Duplicates

$CompareRDSXACountHTML = $CompareRDSXACount.count
$CompareRDSXAHTML = $CompareRDSXA | ConvertTo-Html
$TotalCountRDSXAHTML = $TotalCountRDSXA
$TotalRDSXAlessduplicatesHTML = $TotalRDSXAlessduplicates

$CountRDAXATotalHTML = "<h2>RDS and Citrix Total:<pd>$($TotalCountRDSXAHTML)</pd></h2>"
$CountDuplicateHTML = "<h2>Duplicates in RDS and Citrix Total:<pd>$($CompareRDSXACountHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CompareRDSXAHTML</p> </div>"
$CountTotalRDSXALessDuplicateHTML = "<h2>RDS and Citrix Less Duplicates Total:<pd>$($TotalRDSXAlessduplicatesHTML)</pd></h2>"

##---##

## Code to create HTML Report ##

$Report = ConvertTo-Html -Body "$PageTitle
 $CompExtATT2Count3HTML<p></p>
 $ListCompanyButton1<p></p>
 $ListCompanyButton2<p></p>
 $CountRDSButton<p></p>
 $UserListRDSButton<p></p>
 $CountXAButton<p></p>
 $UserListXAButton<p></p>
 $CountOTButton<p></p>
 $UserListOTButton<p></p>
 $CountRDAXATotalHTML<p></p>
 $CountDuplicateHTML<p></p>
 $CountTotalRDSXALessDuplicateHTML
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
$Report | Out-File -FilePath c:\temp\AD-Company-Account-Type-Report.html
Invoke-Expression c:\temp\AD-Company-Account-Type-Report.html

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue



