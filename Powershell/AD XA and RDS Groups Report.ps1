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
$UniqueExtensionAttribute = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties extensionAttribute2 | Where {$_.Enabled -eq 1} | Sort-Object extensionAttribute2 -Unique | select-object -property extensionAttribute2 -Unique

# Page Title

$PageTitle = "<h1>XA and RDS Groups User List and Counts Report</h1>"

# Title For USer List
$AtlasFilterTitle = "<h5> Count By Attributes </h5>"

########## RDS User List and Count #########

# Gets a list of Groups
$GroupListRDS = Get-ADGroup -Filter * -Properties Name,DistinguishedName | Where {($_.Name -like "*RDS_Users")} | Sort-Object  | Select-Object -Property Name,DistinguishedName


# Gets the AD Group members SamAccountName as per the Group selected
$UserListRDS = foreach ($GroupRDS in $GroupListRDS){
    $ListUsersRDS = Get-ADGroupMember -identity "$($GroupRDS.Name)" | Select-Object -Property SamAccountName
        foreach ($ADUserRDS in $ListUsersRDS){
            $ListRDS = Get-Aduser -Identity $ADUserRDS.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,name,SamAccountName,company
            $ListRDS           
            }
}

# User Table RDS into HTML

$UserListRDSHTML = $UserListRDS | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListRDSButton = "<h2>List RDS Users by ExtensionAttribute2:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListRDSHTML</p> </div>"


# Count each extentionAttribute2


$CountRDS = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetRDS = $UserlistRDS | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsRDS = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetRDS.count)</pd></h2<p></p>"
$AddDetailsRDS
})

# Convert counts to HTML

$TotalCountRDS = $UserListRDS | Measure
#$AddTotalDetailsRDS = "Total" + " " + $TotalCountRDS.count
#$AddTotalDetailsRDS

$TotalCountRDSHTML = $TotalCountRDS.count


$CountRDSHTML = $CountRDS | ConvertTo-Html
$CountRDSButton = "<h2>Total RDS User Count:<pd>$($TotalCountRDSHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CountRDS</p> </div>"


########## XA User List and Count #########

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

# User Table XA into HTML

$UserListXAHTML = $UserListXA | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListXAButton = "<h2>List XA Users by ExtensionAttribute2:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListXAHTML</p> </div>"



# Count each extentionAttribute2

$CountXA = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetXA = $UserlistXA | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsXA = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetXA.count)</pd></h2<p></p>"
$AddDetailsXA
})


$TotalCountXA = $UserListXA | Measure

$TotalCountXAHTML = $TotalCountXA.count


$CountXAHTML = $CountXA | ConvertTo-Html
$CountXAButton = "<h2>Total XA User Count:<pd>$($TotalCountXAHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CountXA</p> </div>"

########## Not in XA or RDS User List and Count #########

$UserListOT = $UserListRDS + $UserListXA


$UserListCountOT = $UserListOT | measure

<#
# Gets a list of Groups
$GroupListOT = Get-ADGroup -Filter * -Properties Name,DistinguishedName | Where {($_.Name -like "*_XA_Users") -or ($_.Name -like "*RDS")} | Sort-Object  | Select-Object -Property Name,DistinguishedName


# Gets the AD Group members SamAccoountName as per the Group selected
$UserListOT = foreach ($GroupOT in $GroupListOT){
    $ListUsersOT = Get-ADGroupMember -identity $GroupOT.Name | Select-Object -Property SamAccountName
        foreach ($ADUserOT in $ListUsersOT){
            $ListOT = Get-Aduser -Identity $ADUserOT.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,name,SamAccountName,company
            $ListOT           
            }
}
#>

# Get List of AD Users
$OUlistOT = get-aduser -filter {Enabled -eq $True} -SearchBase $DC.DistinguishedName | Get-AdUser | Select-Object -Property SamAccountName

# Compare the XA and RDS users againest the AD User list out put not in the XA and RDs group
$ListCompareOT = (compare-object -ReferenceObject $UserListOT -DifferenceObject $OUListOT -Property 'SamAccountName' | ?{$_.sideindicator -eq '=>'}) 

# Get AD User Details
$GetCompareUserOT = foreach ($NameOT in $ListCompareOT){
$ADNameOU = Get-Aduser -Identity $NameOT.SamAccountName -Properties name,company,extensionAttribute2 | Where {$_.Enabled -eq 1} | Select-Object -Property extensionAttribute2,name,SamAccountName,company
            $ADNameOU
            }
          

# User Table OT into HTML

$UserListOTHTML = $GetCompareUserOT | Sort-Object -Property extensionAttribute2,Company | ConvertTo-Html
$UserListOTButton = "<h2>List Other Users by ExtensionAttribute2:  </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$UserListOTHTML</p> </div>"

# Count each extentionAttribute2

$ListCountOT = @(foreach($ExtensionAttribute1 in $UniqueExtensionAttribute){
$GetOT = $GetCompareUserOT  | ?{$_.extensionAttribute2 -eq $($ExtensionAttribute1.extensionAttribute2)} | Select-Object -Property name,company,extensionAttribute2 | Measure
$AddDetailsOT = "<h2>$($ExtensionAttribute1.extensionAttribute2):<pd>$($GetOT.count)</pd></h2<p></p>"
$AddDetailsOT
})

# Measure List Comparison
$TotalCountOT = $ListCompareOT | Measure

# Just get Count number
$TotalCountOTHTML = $TotalCountOT.count


$CountOTHTML = $CountOT | ConvertTo-Html
$CountOTButton = "<h2>Total OT User Count:<pd>$($TotalCountOTHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$ListCountOT</p> </div>"



# Code to create HTML Report

$Report = ConvertTo-Html -Body "$PageTitle
 $CountRDSButton<p></p>
 $UserListRDSButton<p></p>
 $CountXAButton<p></p>
 $UserListXAButton<p></p>
 $CountOTButton<p></p>
 $UserListOTButton<p></p>
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
$Report | Out-File -FilePath .\AD-XA-RDS-Groups-Count-Report.html
Invoke-Expression .\AD-XA-RDS-Groups-Count-Report.html


# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
