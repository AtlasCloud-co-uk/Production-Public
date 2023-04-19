<#
    Info: This script creates new client certificates in bulk against PUL-CA01, then does the conversion to pfx files and then provides passwords in the prompt and then nulls them afterwards.
    Prereq:
        - Install Win64 OpenSSL latest msi from https://slproweb.com/products/Win32OpenSSL.html on the jump box where this is ran
        - Requires csv here: 'C:\PowerShell Scripts\CSV Templates\NetscalerBulkTemplate.csv' with a Username header
        - Requires C:\temp\certs directory
    Author: Martin Purvis
    Modified for Bulk Certificates
#>

#region Variables to change
$organizationName = 'Atlas Cloud' # String used in the certificate metadata
$certificatePrefix = 'MGX' # Certificate filename prefix
$templateCsvFile = 'C:\PowerShell Scripts\CSV Templates\NetscalerBulkTemplate.csv' # File path to the template CSV file
$passwordCharacterSet = (97..122) + (65..90) + (48..57) + [char[]]'!#$^*()-_=+[]{}:.<>'
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" # Path to the openssl executable
#endregion

# Load the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define the path to the custom icon
$iconPath = "C:\Program Files\PowerShellMenu\public\images\menu.ico"

# Display a message box asking the user if they want to create a new CSV or select an existing one
$dialogResult = [System.Windows.Forms.MessageBox]::Show("Do you need to create a new CSV from the template?", "Create CSV or Select Existing", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)

if ($dialogResult -eq [System.Windows.Forms.DialogResult]::Yes) {
    # Create a SaveFileDialog to select where to save the new CSV file
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Title = 'Save the new CSV file'
    $saveFileDialog.Filter = 'CSV Files (*.csv)|*.csv'
    $saveFileDialog.InitialDirectory = 'C:\temp\certs'
    $saveFileDialog.FileName = 'UserImport.csv'

    # Show the SaveFileDialog and get the result
    $saveFileResult = $saveFileDialog.ShowDialog()

    # If the user clicked OK, proceed with copying the template to the new file
    if ($saveFileResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $csvFile = $saveFileDialog.FileName

        # Copy the template CSV to the new CSV file
        Copy-Item $templateCsvFile -Destination $csvFile

        # Create a custom Windows Form
        $form = New-Object System.Windows.Forms.Form
        $form.Text = 'New File Created'
        $form.Size = New-Object System.Drawing.Size(500, 180)
        $form.FormBorderStyle = 'FixedDialog'  # Make the form a fixed size
        $form.MaximizeBox = $false  # Disable the Maximize button
        $form.MinimizeBox = $false  # Disable the Minimize button
        $form.StartPosition = 'CenterScreen'
        $form.Icon = New-Object System.Drawing.Icon($iconPath)

        # Create a label with instructions
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "New file created from template file. Edit this new file:`r`n`r`n$csvFile`r`n`r`nand then run the script again to import."
        $label.AutoSize = $true
        $label.Location = New-Object System.Drawing.Point(10, 10)
        $form.Controls.Add($label)

        # Create a "Copy to Clipboard" button
        $copyButton = New-Object System.Windows.Forms.Button
        $copyButton.Text = 'Copy to Clipboard'
        $copyButton.Size = New-Object System.Drawing.Size(130, 30)  # Adjust the size of the button
        $copyButton.Location = New-Object System.Drawing.Point(10, 100)
        $copyButton.Add_Click({ Set-Clipboard $csvFile })
        $form.Controls.Add($copyButton)

        # Create an "OK" button
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = 'OK'
        $okButton.Location = New-Object System.Drawing.Point(360, 100)
        $okButton.Add_Click({
            $form.Close()
            return  # Stop the script after closing the form
        })
        $form.Controls.Add($okButton)

        # Show the custom form and wait for user input
        $form.ShowDialog() | Out-Null

        # Stop the script after the form is closed
        return
    } else {
        # If the user canceled or closed the SaveFileDialog, exit the script
        return
    }
} elseif ($dialogResult -eq [System.Windows.Forms.DialogResult]::No) {
    # User chose to select an existing CSV, use OpenFileDialog to select the file
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Title = 'Select the CSV file with usernames'
    $openFileDialog.Filter = 'CSV Files (*.csv)|*.csv'
    $openFileDialog.InitialDirectory = 'C:\temp\certs'
    $openFileResult = $openFileDialog.ShowDialog()

    if ($openFileResult -eq [System.Windows.Forms.DialogResult]::OK) {
        $csvFile = $openFileDialog.FileName

        # Check if the CSV file is empty or contains no data
        if ((Get-Content $csvFile | Measure-Object -Line).Lines -le 1) {
            [System.Windows.Forms.MessageBox]::Show('The CSV file is empty or contains no data. Please provide a valid CSV file with usernames.')
            return
        }

        # Import the CSV file and read the usernames from the "Username" column
        $usernames = Import-Csv $csvFile | Select-Object -ExpandProperty Username
    } else {
        # If the user canceled or closed the OpenFileDialog, exit the script
        return
    }
} else {
    # If the user canceled or closed the message box, exit the script
    return
}

# Validate usernames
$allowedCharactersPattern = "^[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-]+$"
$invalidUsernames = $usernames | Where-Object { $_ -notmatch $allowedCharactersPattern }

# Check if there are any invalid usernames
if ($invalidUsernames) {
    # Show a message box indicating invalid usernames
    [System.Windows.Forms.MessageBox]::Show("1 or more rows don't have a valid username", "Invalid Usernames", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    return
}

# Ask the user to check the CSV data
[void][System.Windows.Forms.MessageBox]::Show("Please verify the usernames in the next window.`nRemember to CTRL + A to select all and then click OK!", "Verify Usernames", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)

# Create custom objects with the property name "Username"
$usernamesObjects = $usernames | ForEach-Object {
    [PSCustomObject]@{
        Username = $_
    }
}

# Display the CSV data in Out-GridView for verification and allow the user to select items
$selectedUsernames = $usernamesObjects | Out-GridView -Title 'Verify Usernames' -OutputMode Multiple

# Check if the user selected any usernames or closed the window
if ($selectedUsernames -eq $null -or $selectedUsernames.Count -eq 0) {
    return
}

# Extract the selected usernames as strings from the selected objects
$selectedUsernames = $selectedUsernames.Username

# Create an array to store the username and password information
$userPasswordInfo = @()

# Loop through each selected username and generate certificates
foreach ($username in $selectedUsernames) {
    # Define the subject name
    $subjectName = ("$certificatePrefix-$username--" + (Get-Date -Format 'yyyyMMdd'))
    Write-Output "Working on generating $subjectName........"

    # Define file paths for the key, CSR, certificate, and PFX files
    $outputDirectory = 'C:\temp\certs' # Change this to the desired output directory
    $keyFile = Join-Path $outputDirectory "$subjectName.key"
    $csrFile = Join-Path $outputDirectory "$subjectName.csr"
    $cerFile = Join-Path $outputDirectory "$subjectName.cer"
    $rspFile = Join-Path $outputDirectory "$subjectName.rsp"
    $pfxFile = Join-Path $outputDirectory "$subjectName.pfx"

    # Define the desired password for the PFX file
    $pfxPassword = -join (1..32 | ForEach-Object { [char]($passwordCharacterSet | Get-Random) })

    # Generate a private key and a CSR using openssl
    & $opensslPath req -new -newkey rsa:2048 -nodes -keyout $keyFile -out $csrFile -subj "/C=GB/ST=England/O=$organizationName/CN=$subjectName" > $null 2>&1
    Start-Sleep -Seconds 5

    # Submit the CSR to the Microsoft CA using the certreq tool and save the issued certificate
    & certreq -submit -f -attrib "CertificateTemplate:NetscalerClientCert" -config "PUL-CA01.corp.atlascloud.net\corp-FORNAX-CA" $csrFile $cerFile > $null 2>&1

    # Convert the certificate and private key to a PFX file using openssl
    & $opensslPath pkcs12 -export -out $pfxFile -inkey $keyFile -in $cerFile -password pass:$pfxPassword
    Start-Sleep -Seconds 2

    # Extract the serial number from the certificate
    $certificateSerialNumber = & $opensslPath x509 -in $cerFile -noout -serial
    # Remove the 'serial=' prefix from the serial number
    $certificateSerialNumber = $certificateSerialNumber -replace '^serial=', ''

    # Add the username, password, and certificate serial number to the output object
    $userPasswordInfo += [PSCustomObject]@{
        'Username' = $username
        'PFX Import Password' = $pfxPassword
        'Certificate Serial Number' = $certificateSerialNumber
    }

    # Delete the .key, .csr, .cer, and .rsp files
    Remove-Item $keyFile -Force
    Remove-Item $csrFile -Force
    Remove-Item $cerFile -Force
    Remove-Item $rspFile -Force
}

# Define the CSV file name and path
$csvFileName = "{0:yyyyMMdd-HH_mm}--bulk-generation-{1}.csv" -f (Get-Date), $env:USERNAME
$csvFilePath = Join-Path 'C:\temp\certs' $csvFileName

# Export the username and password information to the CSV file
$userPasswordInfo | Export-Csv -Path $csvFilePath -NoTypeInformation

# Display final instructions
Write-Host @"
You only need to provide the users with their respective PFX files and then give the instructions:

1. Double click the pfx file and import to Current User > Personal store
2. Enter the password provided
3. Navigate to the URL in a browser and select the new certificate from the prompt

You can find the username and password import csv here: $csvFilePath
"@

Read-Host -Prompt "Press enter to close"

# Clear the PFX password variable
$pfxPassword = $null
