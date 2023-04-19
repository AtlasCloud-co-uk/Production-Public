<#
    Info: This script creates a new client certificate against PUL-CA01 and then does the conversion to a pfx file and then provides a password in the prompt and then nulls it afterwards.
    Prereq:
        - Install Win64 OpenSSL latest msi from https://slproweb.com/products/Win32OpenSSL.html on the jump box where this is ran
    Author: Martin Purvis
#>

#region Variables to change
$organizationName = 'Atlas Cloud' # String used in the certificate metadata
$certificatePrefix = 'MGX' # Certificate filename prefix
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe" # Define the path to the openssl executable
$iconPath = "C:\Program Files\PowerShellMenu\public\images\menu.ico" # Define the path to the custom icon
#endregion

# Load the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create a new input dialog using System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Netscaler Client Certificate Generation'
$form.Size = New-Object System.Drawing.Size(500,180) # Adjust the size of the form to accommodate the label
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle # Disable resizing of the window

# Set the custom icon for the input dialog
if (Test-Path $iconPath) {
    $form.Icon = New-Object System.Drawing.Icon($iconPath)
}

# Create a label to display instructions to the user
$label = New-Object System.Windows.Forms.Label
$label.Text = 'Please enter the username of the user who you are creating the certificate for, this script will take care of the rest of the naming.'
$label.AutoSize = $false
$label.Width = 460
$label.Height = 40
$label.Location = New-Object System.Drawing.Point(15,10)
$form.Controls.Add($label)

# Create a textbox to enter the username
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(15,60) # Adjust the position of the text box to accommodate the label
$textBox.Size = New-Object System.Drawing.Size(460,23)
$textBox.MaxLength = 40  # Set the maximum length for the input to 40 characters
$form.Controls.Add($textBox)

# Define the set of allowed characters
$allowedCharacters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-"

# Add an event handler to validate the text box input
$textBox.add_TextChanged({
    # Get the current text in the text box
    $currentText = $textBox.Text

    # Filter out any characters that are not in the allowed set
    $filteredText = ($currentText.ToCharArray() | Where-Object { $allowedCharacters.Contains($_) }) -join ''

    # Update the text box with the filtered text
    if ($filteredText -ne $currentText) {
        $textBox.Text = $filteredText

        # Set the caret position to the end of the text box
        $textBox.SelectionStart = $filteredText.Length
    }

    # Enable or disable the OK button based on whether the text box contains only valid characters and is not empty
    $okButton.Enabled = ($textBox.Text -eq $filteredText) -and ($textBox.Text.Length -gt 0)
})

# Create an OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(200,100) # Adjust the position of the OK button to center it and place it below the text box
$okButton.Size = New-Object System.Drawing.Size(100,25)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton

# Disable the OK button initially
$okButton.Enabled = $false

# Show the input dialog and get the result
$result = $form.ShowDialog()

# If the user clicked OK, set the $subjectName variable
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $username = $textBox.Text
    $subjectName = ("$certificatePrefix-$username--" + (Get-Date -Format 'yyyyMMdd') ) # Define the base name for the certificate, private key, CSR, and PFX files
} else {
    return
}

# Create a new save file dialog using System.Windows.Forms
$saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
$saveFileDialog.Title = 'Select the file location and name'
$saveFileDialog.Filter = 'PFX Files (*.pfx)|*.pfx'
$saveFileDialog.FileName = "$subjectName.pfx" # Set the default file name
$saveFileDialog.InitialDirectory = 'C:\temp\certs'

# Show the save file dialog and get the result
$saveFileResult = $saveFileDialog.ShowDialog()

# If the user clicked OK, set the $outputDirectory and $pfxFile variables
if ($saveFileResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $pfxFile = $saveFileDialog.FileName
    $outputDirectory = Split-Path $pfxFile -Parent
} else {
    # If the user canceled or closed the dialog, exit the script
    return
}

# Use the $outputDirectory variable to specify the file paths for the key, CSR, certificate, and PFX files
$keyFile = Join-Path $outputDirectory "$subjectName.key"
$csrFile = Join-Path $outputDirectory "$subjectName.csr"
$cerFile = Join-Path $outputDirectory "$subjectName.cer"
$rspFile = Join-Path $outputDirectory "$subjectName.rsp"
$pfxFile = Join-Path $outputDirectory "$subjectName.pfx"

# Define the desired password for the PFX file
$pfxPassword = -join (1..32 | ForEach-Object { [char]((97..122) + (65..90) + (48..57) + [char[]]'!#$^*()-_=+[]{}:.<>' | Get-Random) })

Write-Host "Working on $pfxFile"

# Generate a private key and a CSR using openssl
& $opensslPath req -new -newkey rsa:2048 -nodes -keyout $keyFile -out $csrFile -subj "/C=GB/ST=England/O=$organizationName/CN=$subjectName" > $null 2>&1
Start-Sleep -Seconds 5
# Submit the CSR to the Microsoft CA using the certreq tool and save the issued certificate
& certreq -submit -f -attrib "CertificateTemplate:NetscalerClientCert" -config "PUL-CA01.corp.atlascloud.net\corp-FORNAX-CA" $csrFile $cerFile > $null 2>&1

& $opensslPath pkcs12 -export -out $pfxFile -inkey $keyFile -in $cerFile -password pass:$pfxPassword
Start-Sleep -Seconds 2

# Delete the .key, .csr, .cer, and .rsp files
Remove-Item $keyFile -Force
Remove-Item $csrFile -Force
Remove-Item $cerFile -Force
Remove-Item $rspFile -Force

Write-Host @"
You only need to provide the user with $pfxFile and then give the instructions:

1. Double click the pfx file and import to Current User > Personal store
2. Enter the password we provide them
3. Navigate to the URL in a browser and select the new certificate from the prompt
PFX Import password is below:

$pfxPassword

"@

Read-Host -Prompt "Press enter to close"

$pfxPassword = $null
