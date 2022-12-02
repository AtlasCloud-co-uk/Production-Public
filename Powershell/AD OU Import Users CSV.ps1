# Gets a list of OU
$OUList = Get-ADOrganizationalUnit -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName

# Create a Gridview list of Groups, to uses as a selection
$OU = $OUList | Out-GridView -Title "Select OU and Click OK" -OutputMode Single

  
# Store the data from ADUsers.csv in the $ADUsers variable
$CVLocation = Read-host -Prompt "CSV File Location"


# Check path and file location is correct
$TestPath = Test-Path $CVLocation
If ($TestPath)
{
Write-Host "Path/File is Valid" -ForegroundColor Green
}
Else
{
Write-Host "Path/File does not exist" -ForegroundColor Red
Remove-Variable * -ErrorAction SilentlyContinue
Exit
}



# Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv $CVLocation

# Loop through each row containing user details in the CSV file 
foreach ($User in $ADUsers)
{
	# Read user data from each field in each row and assign the data to a variable as below
		
	$Username 	= $User.username
	$Password 	= $User.password
	$Firstname 	= $User.firstname
	$Lastname 	= $User.lastname
    	$Domain     = $User.Domain
	$email      = $User.email
    	$streetaddress = $User.streetaddress
    	$city       = $User.city
    	$PostalCode = $User.postalcode
   	$telephone  = $User.telephone
    	$jobtitle   = $User.jobtitle
    	$company    = $User.company
    	$department = $User.department
    	$extensionAttribute2 = $User.extensionAttribute2


	# Check to see if the user already exists in AD
	if (Get-ADUser -F {SamAccountName -eq $Username})
	{
		 # If user does exist, give a warning
		 Write-Warning "A user account with username $Username already exist in Active Directory."
	}
	else
	{
		# User does not exist then proceed to create the new user account
		
        # Account will be created in the OU provided by the $OU variable read from the CSV file
		New-ADUser `
            -SamAccountName $Username `
            -Name "$Firstname $Lastname" `
            -UserPrincipalName "$Username@$Domain" `
            -GivenName $Firstname `
            -Surname $Lastname `
            -Enabled $True `
            -DisplayName "$Firstname $Lastname" `
            -Path $OU.DistinguishedName `
            -City $city `
            -Company $company `
            -StreetAddress $streetaddress `
            -PostalCode $PostalCode `
            -OfficePhone $telephone `
            -EmailAddress $email `
            -Title $jobtitle `
            -Department $department `
            -AccountPassword (convertto-securestring $Password -AsPlainText -Force) -ChangePasswordAtLogon $True
            -extensionAttribute2 $extensionAttribute2
	}
}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
