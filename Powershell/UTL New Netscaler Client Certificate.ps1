<#
    Info: This script creates a new client certificate against PUL-CA01 and then does the conversion to a pfx file and then provides a password in the prompt and then nulls it afterwards.
    Prereq:
        - Install Win64 OpenSSL latest msi from https://slproweb.com/products/Win32OpenSSL.html on the jump box where this is ran
    Author: Martin Purvis
#>

# Load the System.Windows.Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Define the path to the openssl executable
$opensslPath = "C:\Program Files\OpenSSL-Win64\bin\openssl.exe"

# Create a new input dialog using System.Windows.Forms
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Enter Username'
$form.Size = New-Object System.Drawing.Size(300,150)
$form.StartPosition = 'CenterScreen'

# Create a textbox to enter the username
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(15,25)
$textBox.Size = New-Object System.Drawing.Size(250,23)
$form.Controls.Add($textBox)

# Create an OK button
$okButton = New-Object System.Windows.Forms.Button
$okButton.Location = New-Object System.Drawing.Point(95,60)
$okButton.Size = New-Object System.Drawing.Size(100,25)
$okButton.Text = 'OK'
$okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.Controls.Add($okButton)
$form.AcceptButton = $okButton

# Show the input dialog and get the result
$result = $form.ShowDialog()

# If the user clicked OK, set the $subjectName variable
if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $username = $textBox.Text
    $subjectName = ("MGX-$username--" + (Get-Date -Format 'yyyyMMdd') ) # Define the base name for the certificate, private key, CSR, and PFX files
}

# Create a new folder browser dialog using System.Windows.Forms
$folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
$folderBrowser.Description = 'Select the directory where you want to save the files'
$folderBrowser.SelectedPath = "C:\temp\user" # Set the default folder
$folderBrowser.RootFolder = [Environment+SpecialFolder]::MyComputer

# Show the folder browser dialog and get the result
$folderResult = $folderBrowser.ShowDialog()

# If the user clicked OK, set the $outputDirectory variable
if ($folderResult -eq [System.Windows.Forms.DialogResult]::OK) {
    $outputDirectory = $folderBrowser.SelectedPath
}

# Use the $outputDirectory variable to specify the file paths for the key, CSR, certificate, and PFX files
$keyFile = Join-Path $outputDirectory "$subjectName.key"
$csrFile = Join-Path $outputDirectory "$subjectName.csr"
$cerFile = Join-Path $outputDirectory "$subjectName.cer"
$rspFile = Join-Path $outputDirectory "$subjectName.rsp"
$pfxFile = Join-Path $outputDirectory "$subjectName.pfx"

# Define the desired password for the PFX file
$pfxPassword = -join (1..32 | ForEach-Object { [char]((97..122) + (65..90) + (48..57) + [char[]]'!#$^*()-_=+[]{}:.<>' | Get-Random) })

# Generate a private key and a CSR using openssl
& $opensslPath req -new -newkey rsa:2048 -nodes -keyout $keyFile -out $csrFile -subj "/C=GB/ST=England/O=AtlasCloud/CN=$subjectName"
Start-Sleep -Seconds 5
# Submit the CSR to the Microsoft CA using the certreq tool and save the issued certificate
& certreq -submit -f -attrib "CertificateTemplate:NetscalerClientCert" -config "PUL-CA01.corp.atlascloud.net\corp-FORNAX-CA" $csrFile $cerFile

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