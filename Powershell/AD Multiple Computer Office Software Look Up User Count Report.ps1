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
$PageTitle = "<h1>Office, Visio and Project Software List and Office User Count Report</h1>"

##--------##

########## Import CSV Files ##########

# Note
$Note = "<p class='a'>This information is taken from the Registry and may look to show duplicate values but is correct</p>"

# Import CSV list of software names to search on
Write-Host "This script will loop through the registry looking for both 32bit and 64bit versions." -ForegroundColor Green
$SoftwareName = Import-Csv -Path "C:\Powershell Scripts\CSV\OfficeSoftware.csv"

# Import CSV list of companys using there own licencing 
$CompanysUsingOwnO365Licences = Import-Csv -Path "C:\Powershell Scripts\CSV\CompanyUsingOwnO365.csv"

# Convert list of Software names to HTML
$SoftwareNameHTML = $SoftwareName | ConvertTo-Html -Fragment -Property Software

# Output for HTML Page
$SoftwareRequest = "<h2>Searching for: <h4>$SoftwareNameHTML</h4></h2>"

##--------##

########## Get Computer Choose and Search Registry ##########

# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName,Company | Sort-Object | Select-Object -Property Name,DistinguishedName,Company

# Select Computer from Gridview
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Multiple
Write-Host "Computer: " $ComputerSelect.Name

# Uninstall software reg key locations
$InstalledSoftwareKeyArray = @("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall", "SOFTWARE\\WOW6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall")

# No software installed Array
$CaptureList=@()

# Check each Reg entry and output
$mutli = foreach($comp in $ComputerSelect){
$list=@()
foreach ($InstalledSoftwareKey in $InstalledSoftwareKeyArray){
    Try{
        $InstalledSoftware=[microsoft.win32.registrykey]::OpenRemoteBaseKey(‘LocalMachine’,$Comp.Name)
        $RegistryKey=$InstalledSoftware.OpenSubKey($InstalledSoftwareKey)
        $SubKeys=$RegistryKey.GetSubKeyNames()
              Foreach ($key in $SubKeys){
                $thisKey=$InstalledSoftwareKey+”\\”+$key
                $thisSubKey=$InstalledSoftware.OpenSubKey($thisKey) 
                $object = New-Object PSObject -Property @{
                ComputerName = $Comp.Name
                Company = $Comp.Company
                DisplayName = $($thisSubKey.GetValue(“DisplayName”))
                DisplayVersion = $($thisSubKey.GetValue(“DisplayVersion”))
                BitVersion = $InstalledSoftwareKey
                }
                $object
                }
                if($object | select ComputerName, DisplayName, DisplayVersion, BitVersion,Company | Where {$_.DisplayName -like “*$($SoftwareName)*”}){
                $object| select ComputerName, DisplayName, DisplayVersion, BitVersion,Company | Where {$_.DisplayName -like “*$($SoftwareName)*”}}
                
                
       else{
                $obj2 = New-Object PSObject
                $obj2 | Add-Member -MemberType NoteProperty -Name “ComputerName” -Value $Comp.Name
                $CaptureList += $obj2
                }
        }
        Catch{
            $Errs = $_ 
            
            }
        }
       }

# Show Installed    
$Installed = foreach ($Software in $SoftwareName) {
$mutli | Where {$_.ComputerName -ne $null -and $_.DisplayName -ne $null -and $_.DisplayName -like “*$($Software.software)*” -and $_.DisplayVersion -ne $Null } | Sort-Object -unique -Property ComputerName,DisplayName } 

# Count Installed
$TotalCountInstalled = $Installed | Measure

# Convert to HTML
$TotalCountInstalledHTML = $TotalCountInstalled.count

# Array for Software listed on each machine
$Installed2 = @(foreach ($Software1 in $SoftwareName) {
$multicount = $mutli | Where {$_.ComputerName -ne $null -and $_.DisplayName -ne $null -and $_.DisplayName -like “*$($Software1.software)*” -and $_.DisplayVersion -ne $Null } | Sort-Object -unique -Property ComputerName,DisplayName | measure 

# Create new Table with Software Type and Count
$hash2=[ordered]@{"SoftwareName"="$($Software1.software)"; "SoftwareNameCount"="$($multicount.Count)"}
$obj2 = [pscustomobject]$hash2
$obj2
})

# Get From LoopConvert and change from Table to HTML Layout
$LoopConvertToHTMLInstalled2 = foreach($eachline1 in $Installed2){
$ConvertToHTMLInstalled2 = "<h2>$($Installed2.software):<pd>$($Installed2.Count)</pd></h2><p></p>"
$ConvertToHTMLInstalled2
}

# Convert Installed 2 to HMTL
$Installed2HTML = $Installed2 | convertto-html


# Convert to HTML Output of installed software count
$InstalledHTML = $Installed | Sort-Object -Property ComputerName | ConvertTo-Html
$InstalledButton = "<h2>Software Installed On Total:<pd>$($TotalCountInstalledHTML)</h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$Installed2HTML</p></div>"

# Convert to HTML Output of installed software Computer List
$InstalledHTML2 = $Installed | Sort-Object -Property ComputerName | ConvertTo-Html
$InstalledButton2 = "<h2>Software Installed On: </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$InstalledHTML</p></div>"

# Show where installed just ComputerName
$InstalledComputerName = $Installed | Sort-Object -Property ComputerName | Select-Object ComputerName -Unique 

# Compare Installed againest original selected computer and Installed Computer Names show where differenent
$ListCompareInstalled = (compare-object -ReferenceObject $ComputerSelect.Name -DifferenceObject $InstalledComputerName.ComputerName | ?{$_.SideIndicator -eq '<='}) 

# Compare and show 'No Responce'
$ListNoResponce = (compare-object -ReferenceObject $ComputerSelect.Name -DifferenceObject $mutli.ComputerName | ?{$_.SideIndicator -eq '<='}) 

# Count 'No Respone'
$TotalCountListNoResponce = $ListNoResponce | Measure
# Convert 'No Respone' Count to HTML
$TotalCountListNoResponceHTML = $TotalCountListNoResponce.count

# Convert 'No Responce' to HTML
$ListCompareNoResponceHTML = $ListNoResponce | Sort-Object -Property InputObject | ConvertTo-Html -Property InputObject
$ListCompareNoResponceButton = "<h2>No Repsonse Total:<pd>$($TotalCountListNoResponceHTML)</pd> </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$ListCompareNoResponceHTML</p></div>"


# Compare 
$ListNotInstalled = (compare-object -ReferenceObject @($ListCompareInstalled.InputObject | Select-Object) -DifferenceObject @($ListNoResponce.InputObject | select-object) | ?{$_.SideIndicator -eq '<='})

# Count 'Not Installed'
$TotalCountListNotInstalled = $ListNotInstalled | Measure
# Convert to HTML
$TotalCountListNotInstalledHTML = $TotalCountListNotInstalled.count

# Convert 'Not Installed' to HTML
$ListNotInstalledHTML = $ListNotInstalled | Sort-Object -Property InputObject  | ConvertTo-Html -Property InputObject
$ListNotInstalledButton = "<h2>Software Not Installed On Total:<pd>$($TotalCountListNotInstalledHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$ListNotInstalledHTML</p></div>"

##-------##


########## Company Users ##########

# Parameters
$DC = Get-ADDomain | Select-Object DistinguishedName
$UniqueExtensionAttribute = Get-ADUser -SearchBase $DC.DistinguishedName -Filter * -Properties extensionAttribute2 | Where {$_.Enabled -eq 1} | Sort-Object extensionAttribute2 -Unique | select-object -property extensionAttribute2 -Unique

##-------##

########## RDS User List and Count ##########

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

##-------##

########## Citrix User List and Count ##########

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

##------##

## Get Office Software User List and Count ##

# Combine RDs and XA Uniqure Names and remove duplicates
$Combine = $UserListRDSUnique.SamAccountName + $UserListXAUnique.SamAccountName | Sort-Object -Unique

# Get Unique Company Names
$UniqueInstalled = $Installed | Select-Object -Property Company -unique

# List all Users with Company and ExtenstionAttribute2
$CompanyExtensionAttribute2 = foreach ($UniqueCompanys2 in $UniqueInstalled) {foreach ($UniqueExtensionAttribute2 in $UniqueExtensionAttribute) {
Get-ADUser -filter "Company -like '$($UniqueCompanys2.Company)'"  -Properties Company,extensionAttribute2 -ErrorAction SilentlyContinue | Where {($_.Enabled -eq 1) -and ($_.extensionAttribute2 -eq $($UniqueExtensionAttribute2.extensionAttribute2))} | Sort-Object -Property Company,Name,SamAccountName | Select-Object -property Name,SamAccountName,Company,extensionAttribute2
}
}

# Compare Installed User List againest Duplicate 
$CompareInstalledDuplicate = compare-Object -ReferenceObject $Combine -DifferenceObject $CompanyExtensionAttribute2.SamAccountName -IncludeEqual -ExcludeDifferent

# Get ADUSer details from Compared List
$GetADUser = foreach ($GetADUSerInfo in $CompareInstalledDuplicate) {
Get-Aduser -filter "SamAccountName -like  '$($GetADUSerInfo.InputObject)'" -Properties Company,extensionAttribute2 | Select-Object -property Name,SamAccountName,Company,extensionAttribute2 }

# Sort GetADUSer List
$GetADUserSort = $GetADUser | Sort-Object -Property Company,Name

# HTML GetADUSer List
$GetADUserSortHTML = $GetADUserSort | ConvertTo-Html

# HTML Office Software User List
$OfficeUserListInstalledButton = "<h2>Office Software User List: </h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$GetADUserSortHTML</p></div>"

# Measure GetADUSer List
$MesureADUSerList = $GetADUser | measure

# HTML for GetADUser Count
$CountADUsersHTML = $MesureADUSerList.count

# Get the unique Company Name from the ADUSer List
$GetUnigueCompanyName = $GetADUser | Select-Object -Property Company -Unique

# Check Each User againest AD and get company name, add user count for Each Company
$CompanyCount = @(foreach ($GetUnigueCompanyName1 in $GetUnigueCompanyName) {
$GetADUserCount = $GetADUserSort | Where {$_.Company-like “*$($GetUnigueCompanyName1.company)*”} | measure 

# Create new Table with Software Type and Count
$hash2=[ordered]@{"Company"="$($GetUnigueCompanyName1.company)"; "Office Count"="$($GetADUserCount.Count)"}
$obj2 = [pscustomobject]$hash2
$obj2
})

# Sort into Company Order 
$CompanyOrder = $CompanyCount | Sort-Object -Property Company

#Convert Company Count to HTML
$CompanyCountHTML = $CompanyOrder | ConvertTo-Html

# Convert to HTML Display Software Total and Company Table
$CompanyCountInstalledButton = "<h2>Office Software Users Total:<pd>$($CountADUsersHTML)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CompanyCountHTML</p></div>"

##--------##

########## Get Office count minus company/s using there Own Office Licencing ##########

# Get Companies using there own 365 accounts on dedicated hardware
$GetCompanys = foreach ($CompanyO365 in $CompanysUsingOwnO365Licences)
{$CompanyCount | Where {$_.Company -like "$($CompanyO365.company)"}} 

# The Office Count number/s
$GetCompanysCount = $GetCompanys.'Office Count'

# Total Office Count Numbers
$TotalCompanysCount = $GetCompanysCount | Measure-Object -Sum

# Display Only Total Comapny Office Sum
$SumCompanysCount = $TotalCompanysCount.Sum

# Subtract Companys licence Total from Total Office Count
$SubtractUsing365 = $MesureADUSerList.Count - $SumCompanysCount

# HTML for Subtraction
$SubtractUsing365HTML = $SubtractUsing365

# HTML Company Using Own o365 Licences
$CompanysUsingOwnO365LicencesHTML = $GetCompanys | ConvertTo-Html

# Convert to HTML Display Software Total and Company Table
$SubtractUsing365CountInstalledButton = "<h2>Office Software Users less Company Own Used Licences Total:<pd>$($SubtractUsing365)</pd></h2><button type='button' class='collapsible'><h3>+</h3></button> <div class='content'><p>$CompanysUsingOwnO365LicencesHTML</p></div>"

##--------##

########## Code to create HTML Report ##########

$Report = ConvertTo-Html -Body "$PageTitle
 $SoftwareRequest<p></p>
 $InstalledButton<p></p>
 $InstalledButton2<p></p>
 $ListNotInstalledButton<p></p>
 $ListCompareNoResponceButton<p></p>
 $CompanyCountInstalledButton<p></p>
 $OfficeUserListInstalledButton<p></p>
 $SubtractUsing365CountInstalledButton<p></p>
   " -Title "Software List Report" -Head $header -PostContent "<script>
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
$Report | Out-File -FilePath c:\temp\Software-User-List-Report.html
Invoke-Expression c:\temp\Software-User-List-Report.html

##-------##

########## Convert to CSV ##########

# Confirmation to Proceed for CSV export
$ExporToCSV = Read-Host -Prompt "Export to CSV"

# Validate Confirmation
If ([string]::IsNullOrWhiteSpace($ExporToCSV))
{
    Write-Host "No CSV Required" -ForegroundColor Red
    Remove-Variable * -ErrorAction SilentlyContinue
    $ExporToCSV= Exit
}
elseif ($ExporToCSV -eq "no") {
    Write-Host "No CSV Required" -ForegroundColor Red
    Remove-Variable * -ErrorAction SilentlyContinue
    Exit
  }
elseif ($ExporToCSV -eq "N") {
    Write-Host "No CSV Required" -ForegroundColor Red
    Remove-Variable * -ErrorAction SilentlyContinue
    Exit
    }
elseif ($ExporToCSV -eq "Y") {
      
        $CSVName = Read-Host -Prompt "Supply CSV name"
        $Installed | select ComputerName, Company, DisplayName, DisplayVersion, BitVersion | Export-Csv -append -path c:\temp\$($CSVName).csv
        Remove-Variable * -ErrorAction SilentlyContinue
        }
       
elseif ($ExporToCSV -eq "Yes") {
        $CSVName = Read-Host -Prompt "Supply CSV name"
        $Installed| select ComputerName, Company, DisplayName, DisplayVersion, BitVersion | Export-Csv -append -path c:\temp\$($CSVName).csv
        Remove-Variable * -ErrorAction SilentlyContinue
        }


# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue

