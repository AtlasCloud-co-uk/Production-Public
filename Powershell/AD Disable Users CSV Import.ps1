## Param ##

# Import OU Filter
$OUFilterListImport = Import-Csv -Path "C:\PowerShell Scripts\CSV\ADDisableOUFilter.csv"

# Import a list to filter the MemberOf Group
$GetUserFilterList = Import-Csv -Path "C:\PowerShell Scripts\CSV\ADDisableMemberOfFilter.csv"


## Start Script ##

# Get Ticket Number
$Description = Read-Host -Prompt "Enter Ticket Number"

# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

#  Filter Out not required OU's for Grid View
$OUFilter1 = $OUList| Where-Object {$_.DistinguishedName | select-string -notmatch $OUFilterListImport.ou}

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUFilter1 | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

# Store the data from ADUsers.csv in the $ADUsers variable
$CVLocation = Read-host -Prompt "File Location"

# Check path and file location is correct
$TestPath = Test-Path $CVLocation
If ($TestPath)
{
Write-Host "`n Path/File is Valid `n" -ForegroundColor Green
}
Else
{
Write-Host "`n Path/File does not exist `n" -ForegroundColor Red
Remove-Variable * -ErrorAction SilentlyContinue
Exit
}

# Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv $CVLocation

# Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	# Read user data from each field in each row and assign the data to a variable as below
		
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
    

	# Check to see if the user already exists in AD
	
        if (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree | Where {$_.Enabled -eq 1})
	{
		 # If user does exist and enabled
		 Write-Host "User account $firstname $lastname is enabled and does exist in Active Directory:" $OU.Name -ForegroundColor Green
	}
    elseif 
    (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree | Where {$_.Enabled -eq 0})
	{
		 # If user does exist and disabled
		 Write-Host "User account $firstname $lastname is disabled and does exist in Active Directory:" $OU.Name -ForegroundColor Cyan 
	}


	else
	{
		# User does not exist.
		
         Write-Warning "User account $firstname $lastname does not exist in Active Directory." 
	}
}

# Output to check users imported list is correct
Write-Host "`n *** Confirm that All Users Were Valid or Disabled ***" -foregroundcolor Red

# Fuction to disable users and hide from Global Address List (Address Book) 
function Show-AskDisableAccount {

		# Ask for confirmation that accounts can be disabled as previous check is all good.
		$AskForConfirmation1 = @"

[1] Users are Valid, Continue to Disable Accounts
[2] Exit

Type a number and press enter
"@
		
		$AskForConfirmationResponse1 = Read-Host -Prompt $AskForConfirmation1
		switch ($AskForConfirmationResponse1) {
			"1"  { }  
			"2"  { Write-Host "Exiting" -ForegroundColor Green; Exit}
			Default {Write-Host "One of the listed numbers was not entered";exit}
		}
            if ($AskForConfirmationResponse1 -eq "1"){$SAMAccount =  foreach ($Users in $ADUsers) {
                $Firstname 	= $Users.firstname
	            $Lastname 	= $Users.lastname
                Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -Properties samAccountName -SearchBase $OU.DistinguishedName -SearchScope Subtree | Select-Object -Property samAccountName
                }
                foreach ($SAMAccount1 in $SAMAccount){ Disable-ADAccount -Identity $SAMAccount1.SamAccountname;
                Set-ADUser -identity $SAMAccount1.SamAccountname -Replace @{msExchHideFromAddressLists="TRUE"};
                Set-ADUser -identity $SAMAccount1.SamAccountname -Description $Description}
                    foreach ($Users in $ADUsers){
                        Start-Sleep -s 3
                        $Firstname 	= $Users.firstname
	                    $Lastname 	= $Users.lastname
                        if (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree | Where {$_.Enabled -eq 1})
	                    {
		                # If user is still enabled, give a warning
		                 Write-Warning "User account $firstname $lastname is still enabled."
                	            }
                        elseif 
                         (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree -Properties * | Where {$_.Enabled -eq 0 -and $_.msExchHideFromAddressLists -eq 1})
	                    {
		                # If user has been disabled and hidden from the GAL
		                Write-Host "User account $firstname $lastname has been disabled and hidden from AD Global Address List." -ForegroundColor Green
	                    }
        }
        }
}       
Show-AskDisableAccount

# Output to check that the Users are disabled
Write-Host "`n *** Confirm that All Users Were Disabled ***" -foregroundcolor Red

# Function to move users to the disabled users OU
function Show-AskMoveAccountstoDisabledFolder {

		# Move users to disabled OU
		$AskForConfirmation2 = @"

[1] Users are Disabled, move Users to the Disabled Users OU
[2] Users not have a Valid Disabled Users OU, Continue to Removing MemberOf
[3] Exit

Type a number and press enter
"@
		
		$AskForConfirmationResponse2 = Read-Host -Prompt $AskForConfirmation2
		switch ($AskForConfirmationResponse2) {
			"1" {}
            "2" {Show-AskRemoveMemberOf}
			"3" {Write-Host "Exiting" -ForegroundColor Green;Exit}
			Default {Write-Host "One of the listed numbers was not entered";exit}
            }
            if ($AskForConfirmationResponse2 -eq "1"){
                    $OUDisabled = $OUList| Where-Object {$_.DistinguishedName -like "*$($ou.DistinguishedName)*"}
                    $OUConfirmedDisabledOU = $OUDisabled | Where-Object {$_.Name -eq "Disabled Users"}
                    if ($OUConfirmedDisabledOU -eq $null)
                    {Write-Warning "No Disabled Users OU available!";Show-AskMoveAccountstoDisabledFolder}
                    else
                    {Write-Host "`n Moving Users `n" -ForegroundColor Yellow
                        $SAMAccount =  foreach ($Users in $ADUsers) {
                            $Firstname 	= $Users.firstname
	                        $Lastname 	= $Users.lastname
                            Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -Properties samAccountName -SearchBase $OU.DistinguishedName -SearchScope Subtree | Select-Object -Property samAccountName
                                }
                            foreach ($SAMAccount1 in $SAMAccount){Get-ADUser -Identity $SAMAccount1.SamAccountname | Move-ADObject -TargetPath $OUConfirmedDisabledOU.DistinguishedName }
                                foreach ($Users in $ADUsers){
                                    $Firstname 	= $Users.firstname
	                                $Lastname 	= $Users.lastname
                                    if (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree | Where-object {$_.DistinguishedName -like "*disabled*"})
	                                {
		                            # If user has been moved to the disabled users OU
		                            Write-Host "User account $firstname $lastname has been moved." -ForegroundColor Green
                	                    }
                                    elseif 
                                        (Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -SearchBase $OU.DistinguishedName -SearchScope Subtree -Properties * | Where-object {$_.DistinguishedName -notlike "*disabled*"})
	                                {
		                            # If user has not been moved to the disabled users OU
		                            Write-Warning "User account $firstname $lastname has not been moved." 
	                                }
                                    }
                                    }
                    }

		}

Show-AskMoveAccountstoDisabledFolder

# Output to check that the users have been moved
Write-Host "`n *** Confirm that All Users Have Been Moved to the Disabled Users Folder ***" -foregroundcolor Red

# Information that certains MemberOf Groups will be left
Write-Host "`n (Users will not be removed from the Domain Users and SSPR MemberOf Group)" -ForegroundColor Green

# Function to Remove unessary Member Of Groups
function Show-AskRemoveMemberOf {

		# Move users to disabled OU
		$AskForConfirmation3 = @"

[1] Remove MemberOf Groups
[2] Exit


Type a number and press enter
"@
		
		$AskForConfirmationResponse3 = Read-Host -Prompt $AskForConfirmation3
		switch ($AskForConfirmationResponse3) {
			"1" {}
			"2" {Write-Host "Exiting" -ForegroundColor Green;Exit}
			Default {Write-Host "One of the listed numbers was not entered";exit}
            }
            if ($AskForConfirmationResponse3 -eq "1"){
                    $OUDisabled = $OUList| Where-Object {$_.DistinguishedName -like "*$($ou.DistinguishedName)*"}
                    $OUConfirmedDisabledOU = $OUDisabled | Where-Object {$_.Name -eq "Disabled Users"}
                    if ($OUConfirmedDisabledOU -eq $null)
                    {Write-Warning "No Disabled Users OU available!"}
                    else
                    {Write-Host "`n Removing from MemberOf `n" -ForegroundColor Yellow
                        $SAMAccount =  foreach ($Users in $ADUsers) {
                            $Firstname 	= $Users.firstname
	                        $Lastname 	= $Users.lastname
                            Get-ADUser -F 'GivenName -eq $firstname -and sn -eq $lastname' -Properties samAccountName -SearchBase $OU.DistinguishedName -SearchScope Subtree | Select-Object -Property samAccountName
                                }
                            foreach ($SAMAccount1 in $SAMAccount){$GetUserMemberList = Get-ADPrincipalGroupMembership $SAMAccount1.samAccountName | Select-Object -Property Name | Where-object {$_.name | select-string -notmatch $GetUserFilterList.MemberOf}
                                
                                        if ($GetUserMemberList -eq $Null)
                                        {$Name = Get-ADUser -Identity $SAMAccount1.samAccountName | Select-Object Name
                                          Write-Host "User Account $($Name.name) had no MemberOf groups require removing." -ForegroundColor Cyan}
                                        else{
                                        foreach ($GetUserMemberLists in $GetUserMemberList){Remove-ADGroupMember -Identity $GetUserMemberLists.name -Members $SAMAccount.samAccountName -Confirm:$false
                                            $Name = Get-ADUser -Identity $SAMAccount1.samAccountName | Select-Object Name
                                            Write-Host "User Account $($Name.name) MemberOf Group $($GetUserMemberLists.name) have been removed." -ForegroundColor Green}
                                             }
                                    }
                             }
                    }

		}

Show-AskRemoveMemberOf

# Output to check that the Users are disabled
Write-Host "`n *** Confirm that MemberOf Groups have been removed ***" -foregroundcolor Red

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
