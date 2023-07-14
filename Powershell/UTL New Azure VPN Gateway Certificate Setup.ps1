<#
    This script is intended to provide a self-signed root certificate and accompanying client certificates signed by the root, to be used in Azure VPN Gateway setups to automate the process.
    Script has 2 parts:
    1. Create the root certificate for a customer (or skip if you have it imported already in your current user personal store)
    2. Create client certificates against the root cert of your choice, provided by a csv of your choosing.

    The script will ask you to choose a working directory where it spits out files related to the specific customer:
    - _export.csv -- this file will show you the name of each client pfx, each import password, the file path and the expiry date of the certificate
    - _export-skipped.csv -- this file will show you a list of usernames you provided that contain illegal characters such as spaces, or non standard special characters that shouldn't be in filenames
    - _rootCertificate.cer -- this file contains the full base64 string to import to Azure
    Also, all client certificates with the prefix of your choosing.

    Script is messy but it works, just ask for help if you need to.

    This script is intended to automate VPN Gateway Root cert and Client cert generation as described:
    https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-certificates-point-to-site

    Author: Martin Purvis
    Date: 2023-07-14
#>



# Add the required assemblies
Add-Type -AssemblyName System.Windows.Forms

function Get-CompanyPrefix {
    $companyPrefixInputBox = New-Object System.Windows.Forms.TextBox
    $companyPrefixInputBox.Size = New-Object System.Drawing.Size(600, 40)
    $companyPrefixInputBox.TextAlign = [System.Windows.Forms.HorizontalAlignment]::Center
    $companyPrefixInputBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 14)

    $companyPrefixForm = New-Object System.Windows.Forms.Form
    $companyPrefixForm.Text = "Enter the company prefix"
    $companyPrefixForm.Width = 800
    $companyPrefixForm.Height = 400
    $companyPrefixForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $companyPrefixForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen

    $companyPrefixInputBox.Left = ($companyPrefixForm.Width - $companyPrefixInputBox.Width) / 2
    $companyPrefixInputBox.Top = ($companyPrefixForm.Height - $companyPrefixInputBox.Height - 80) / 2

    $companyPrefixForm.Controls.Add($companyPrefixInputBox)

    $companyPrefixOKButton = New-Object System.Windows.Forms.Button
    $companyPrefixOKButton.Text = "OK"
    $companyPrefixOKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $companyPrefixOKButton.Width = 100
    $companyPrefixOKButton.Height = 40
    $companyPrefixOKButton.Left = ($companyPrefixForm.Width - $companyPrefixOKButton.Width) / 2
    $companyPrefixOKButton.Top = $companyPrefixInputBox.Bottom + 30

    $companyPrefixForm.AcceptButton = $companyPrefixOKButton
    $companyPrefixForm.Controls.Add($companyPrefixOKButton)

    if ($companyPrefixForm.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        return $companyPrefixInputBox.Text
    }
    else {
        Write-Output "No company prefix entered."
        exit
    }
}

# Prompt to choose whether to execute RootCertGenerationScript
$result = [System.Windows.Forms.MessageBox]::Show("Do you want to create a new Root Cert?", "Script Selection", 'YesNo', 'Question')
if ($result -eq 'Yes') {
# RootCertGenerationScript

#region MessageBox1
$result = $null
do {
    $result = [System.Windows.Forms.MessageBox]::Show("On the next folder picker window, select a temporary customer-specific folder to export to.", "Folder Selection", 'OK', 'Information')
} while ($result -ne 'OK')
$result = $null
#endregion MessageBox1

#region FolderPicker

# Create an instance of the OpenFileDialog class
$folderDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set the dialog box properties
$folderDialog.Title = "Select a folder"
$folderDialog.CheckFileExists = $false
$folderDialog.CheckPathExists = $true
$folderDialog.ValidateNames = $false
$folderDialog.FileName = "Select Folder"
$folderDialog.Filter = "Folders|*.fakeextension"

# Show the dialog box and check if the user clicked the OK button
if ($folderDialog.ShowDialog() -eq 'OK') {
    # Get the selected folder path
    $selectedFolder = Split-Path -Path $folderDialog.FileName

    # Output the selected folder path
    Write-Host "Selected folder: $selectedFolder"
}
else
{
    Write-Host "Didn't pick a folder"
    break
}
#endregion FolderPicker

#region MessageBox2
$result = $null
do {
    $result = [System.Windows.Forms.MessageBox]::Show("On the next window, enter the prefix name of the customer you are doing this for.", "Folder Selection", 'OK', 'Information')
} while ($result -ne 'OK')
$result = $null
#endregion MessageBox2

$CompanyPrefix = Get-CompanyPrefix

$RootCertName = "$CompanyPrefix-P2SRootCert"

$RootCert = New-SelfSignedCertificate -Type Custom `
                                     -KeySpec Signature `
                                     -Subject "CN=$RootCertName" `
                                     -KeyExportPolicy Exportable `
                                     -HashAlgorithm sha256 -KeyLength 2048 `
                                     -CertStoreLocation "Cert:\CurrentUser\My" `
                                     -KeyUsageProperty Sign `
                                     -KeyUsage CertSign

$rootCertPath = "$selectedFolder\_rootCertificate.cer"

$certBytes = $RootCert.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert)
$base64Cert = [System.Convert]::ToBase64String($certBytes)
$base64Cert | Out-File -FilePath $rootCertPath -Encoding ASCII

Write-Output @"
**Info**
Root certificate name:`t$RootCertName
Root certificate path:`t$rootCertPath
Root certificate thumbprint:`t$($RootCert.Thumbprint)
Root certificate base64:`t$base64Cert

The base64 data of the root certificate has also been exported to `"$rootCertPath`".
You need to copy this string to the Azure VPN Gateway certificate section.

"@

}
else {
    Write-Output "Skipping RootCertGenerationScript."
}

# ClientCertGenerationScript

#region MessageBox1
$result = $null
do {
    $result = [System.Windows.Forms.MessageBox]::Show("On the next folder picker window, select a temporary customer-specific folder to export to. Best keep this the same as where you exported the root cert", "Folder Selection", 'OK', 'Information')
} while ($result -ne 'OK')
$result = $null
#endregion MessageBox1

#region FolderPicker

# Create an instance of the OpenFileDialog class
$folderDialog = New-Object System.Windows.Forms.OpenFileDialog

# Set the dialog box properties
$folderDialog.Title = "Select a folder"
$folderDialog.CheckFileExists = $false
$folderDialog.CheckPathExists = $true
$folderDialog.ValidateNames = $false
$folderDialog.FileName = "Select Folder"
$folderDialog.Filter = "Folders|*.fakeextension"

# Show the dialog box and check if the user clicked the OK button
if ($folderDialog.ShowDialog() -eq 'OK') {
    # Get the selected folder path
    $selectedFolder = Split-Path -Path $folderDialog.FileName

    # Output the selected folder path
    Write-Host "Selected folder: $selectedFolder"
}
else
{
    Write-Host "Didn't pick a folder"
    break
}
#endregion FolderPicker

#region MessageBox2
$result = $null
do {
    $result = [System.Windows.Forms.MessageBox]::Show("On the next folder picker window, select the customer root cert you created, it will have P2SRootCert in the title...", "Folder Selection", 'OK', 'Information')
} while ($result -ne 'OK')
$result = $null
#endregion MessageBox2

$certificates = Get-ChildItem -Path 'Cert:\CurrentUser\My' | Where-Object { $_.Subject -like '*RootCert*' }

if ($certificates.Count -eq 0) {
    Write-Output "No certificates found in 'CurrentUser\My'. Exiting script."
    exit
}

$selectedCert = $certificates | Out-GridView -Title "Select the root certificate" -PassThru

if ($null -eq $selectedCert) {
    Write-Output "No root certificate selected. Exiting script."
    exit
}

$rootCertThumbprint = $selectedCert.Thumbprint
$RootCert = Get-ChildItem -Path "Cert:\CurrentUser\My\$rootCertThumbprint"
$DateFormat = Get-Date -Format "yyyy-MM-dd"

#region MessageBox3
$result = $null
do {
    $result = [System.Windows.Forms.MessageBox]::Show("You're now going to be asked to import a csv containing a list of usernames for each user, you MUST have a header called Usernames or this won't work...", "Folder Selection", 'OK', 'Information')
} while ($result -ne 'OK')
$result = $null
#endregion MessageBox3


$templateCsvFile = 'C:\PowerShell Scripts\CSV Templates\GenericUsernamesTemplate.csv' # File path to the template CSV file

#region CSVOptions
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
        $form.Size = New-Object System.Drawing.Size(1000, 500)
        $form.FormBorderStyle = 'FixedDialog'  # Make the form a fixed size
        $form.MaximizeBox = $false  # Disable the Maximize button
        $form.MinimizeBox = $false  # Disable the Minimize button
        $form.StartPosition = 'CenterScreen'

        # Create a label with instructions
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "New file created from template file. Edit this new file:`r`n`r`n$csvFile`r`n`r`nand then run the script again to import."
        $label.AutoSize = $true
        $label.Location = New-Object System.Drawing.Point(10, 10)
        $form.Controls.Add($label)

        # Create a "Copy to Clipboard" button
        $copyButton = New-Object System.Windows.Forms.Button
        $copyButton.Text = 'Copy to Clipboard'
        $copyButton.Size = New-Object System.Drawing.Size(200, 50)  # Adjust the size of the button
        $copyButton.Location = New-Object System.Drawing.Point(200, 200)
        $copyButton.Add_Click({ Set-Clipboard $csvFile })
        $form.Controls.Add($copyButton)

        # Create an "OK" button
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Text = 'OK'
        $okButton.Size = New-Object System.Drawing.Size(200, 50)  # Adjust the size of the button
        $okButton.Location = New-Object System.Drawing.Point(500, 200)
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
        $usernames = Import-Csv $csvFile | Select-Object -ExpandProperty Usernames
    } else {
        # If the user canceled or closed the OpenFileDialog, exit the script
        return
    }
} else {
    # If the user canceled or closed the message box, exit the script
    return
}
#endregion CSV Options


    $csvFilePath = $openFileDialog.FileName

    # Import the CSV data
    $csvData = Import-Csv -Path $csvFilePath
    

    if (-not $CompanyPrefix) {
         #region MessageBox4
        $result = $null
        do {
            $result = [System.Windows.Forms.MessageBox]::Show("On the next window, enter the prefix name of the customer you are doing this for.", "Folder Selection", 'OK', 'Information')
        } while ($result -ne 'OK')
        $result = $null
        #endregion MessageBox4
        $CompanyPrefix = Get-CompanyPrefix
    }

        # Extract the usernames from the CSV data
        $usernames = $csvData.Usernames.Trim()

        # Define the allowed characters pattern
        $allowedCharactersPattern = "^[ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789.-]+$"

        # Create an array to hold the export data for valid certificates
        $validExportData = @()

        # Create an array to hold the skipped usernames
        $skippedUsernames = @()

        # Loop through each username
        foreach ($username in $usernames) {
            $trimmedUsername = $username.Trim()

            # Validate the username against the allowed characters pattern
            if ($trimmedUsername -match $allowedCharactersPattern) {
                $ClientCertDnsName = "$CompanyPrefix-$trimmedUsername-$DateFormat"

                $passwordCharacterSet = [char[]]'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!#$^*()-_=+[]{}:.<>'
                $password = -join ($passwordCharacterSet | Get-Random -Count 16)

                # Create a new client certificate signed by the root certificate
                $clientCert = New-SelfSignedCertificate -Type Custom `
                                                       -DnsName $ClientCertDnsName `
                                                       -KeySpec Signature `
                                                       -Subject "CN=$ClientCertDnsName" `
                                                       -KeyExportPolicy Exportable `
                                                       -HashAlgorithm sha256 `
                                                       -KeyLength 2048 `
                                                       -CertStoreLocation "Cert:\CurrentUser\My" `
                                                       -Signer $RootCert `
                                                       -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.2")

                # Export the client certificate as a PFX file
                $clientCertPath = "$selectedFolder\$ClientCertDnsName.pfx"
                $pfxPassword = ConvertTo-SecureString -String $password -Force -AsPlainText
                Export-PfxCertificate -Cert $clientCert -FilePath $clientCertPath -Password $pfxPassword

                # Get the certificate expiration date
                $expirationDate = $clientCert.NotAfter

                # Create the export data for the valid certificate
                $validData = [PSCustomObject]@{
                    CertificateName = $ClientCertDnsName
                    ImportPassword = $password
                    FilePath = $clientCertPath
                    ExpiryDate = $expirationDate
                }
                $validExportData += $validData
            }
            else {
                # Add the skipped username to the array
                $skippedUsernames += $trimmedUsername
            }
        }

        # Export the valid certificates to a CSV file
        $validExportData | Export-Csv -Path "$selectedFolder\_export.csv" -NoTypeInformation

        # Export the skipped usernames to a CSV file
        $skippedData = $skippedUsernames | ForEach-Object {
            [PSCustomObject]@{
                SkippedUsername = $_
                Reason = "Invalid characters"
            }
        }
        $skippedData | Export-Csv -Path "$selectedFolder\_export-skipped.csv" -NoTypeInformation

        Write-Output "Certificate generation and export complete!"
    


#endregion

