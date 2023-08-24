<#
    This script checks against servers to see which has the old and new *.atlascloud.co.uk wildcard certificates installed in the computer personal store.
    This is handy to get a list of what we need to update at annual renewal of the certificate.
    Ability to save results to a csv.
    --mpurvis
#>

# Define the certificate thumbprints and their descriptions --update these each year
$thumbprints = @{
    "a955099f5c71eed9099b9ab2cee5894b211ad17c" = "New *.atlascloud.co.uk wildcard certificate"
    "22acd2de425908eea1a042859333149cbd0175e4" = "Old *.atlascloud.co.uk wildcard certificate"
}

# Select enabled devices using Out-GridView
$selectedDevices = Get-ADComputer -Filter {Enabled -eq $true} |
    Sort-Object Name |
    Out-GridView -Title "Select enabled devices" -PassThru

Write-Host "Please wait..."

# Define the script block to run on remote devices
$scriptBlock = {
    param($thumbprints)

    $results = @()

    foreach ($thumbprint in $thumbprints.Keys) {
        $cert = Get-ChildItem -Path Cert:\LocalMachine\My | Where-Object { $_.Thumbprint -eq $thumbprint }

        if ($cert) {
            $certInfo = [PSCustomObject]@{
                ComputerName = $env:COMPUTERNAME
                Thumbprint = $thumbprint
                Description = $thumbprints[$thumbprint]
            }
            $results += $certInfo
        }
    }

    $results
}

# Execute the script block on selected devices
$results = Invoke-Command -ComputerName $selectedDevices.Name -ScriptBlock $scriptBlock -ArgumentList $thumbprints -ErrorAction SilentlyContinue

# Display formatted results sorted by ComputerName
$resultsSorted = $results | Sort-Object ComputerName
$resultsSorted | Format-Table -AutoSize -Property ComputerName, Thumbprint, Description

# Prompt to save results to a CSV file
$saveToFile = Read-Host "Do you want to save the results to a CSV file? (Y/N)"

if ($saveToFile -eq 'Y' -or $saveToFile -eq 'y') {
    $fileDialog = New-Object Microsoft.Win32.SaveFileDialog
    $fileDialog.Title = "Select File Location to Save CSV"
    $fileDialog.Filter = "CSV Files (*.csv)|*.csv"
    $fileDialog.InitialDirectory = [Environment]::GetFolderPath("MyDocuments")
    $fileDialog.FileName = "CertificateResults.csv"

    $dialogResult = $fileDialog.ShowDialog()

    if ($dialogResult -eq 'OK') {
        $csvFilePath = $fileDialog.FileName
        $resultsSorted | Select-Object ComputerName, Thumbprint, Description |
            Export-Csv -Path $csvFilePath -NoTypeInformation
        Write-Host "Results saved to $csvFilePath"
    }
}

