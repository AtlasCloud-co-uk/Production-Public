#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Opening 64-bit powershell....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NonInteractive -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}


write-host "Starting Main script body"

#############################################################################
#End
#############################################################################  

# Connect to Office 365
Connect-MsolService

# Save CSV Location
Write-Host "Export Path and CSV file name " -NoNewline
Write-Host "(Example: c:\Temp\ADUserlist.csv): " -ForegroundColor Green -NoNewline
$CSVExportPath = Read-Host

# Export Enabled Only User/s Account/s to csv
Get-MsolUser | Where-Object BlockCredential -match "False" | Sort-Object -Property DisplayName | Select-Object DisplayName,UserPrincipalName,BlockCredential | Export-Csv $CSVExportPath

# Location for import CSV file
Write-Host "Remove any Admin or Service accounts from the Exported CSV before proceeding" -ForegroundColor Red
Write-Host "Import Path and CSV File or " -NoNewline
Write-Host "Press Enter Yes to use previous Path: " -ForegroundColor Green -NoNewline
$CSVImportPath = Read-Host

# Message Filter Default Input if nothing has been entered
If ([string]::IsNullOrWhiteSpace($CSVImportPath))
    {   
    Write-Host "Existing" -ForegroundColor Green
    $RevokeSession = Exit
    }
else { if ($CSVImportPath -eq "Yes") {
    $CSVImportPath = $CSVExportPath
        }
    }   

# Import CSV file to variable
$ImportCSV = Import-Csv $CSVImportPath

# Check Import List
$ImportCSV.UserPrincipalName

# Change ForcePassword on next log based in the Imported CSV file
Write-Host "Type Yes to Contiune Import? " -NoNewline
Write-Host "(No is default): " -ForegroundColor Green -NoNewline
$ForcePassword = Read-Host

# Message Filter Default Input if nothing has been entered
If ([string]::IsNullOrWhiteSpace($ForcePassword))
{
    Write-Host "Existing" -ForegroundColor Green
    $ForcePassword= Exit
}
elseif ($ForcePassword -eq "no") {
    Write-Host "Existing" -ForegroundColor Green
    Exit
  }
elseif ($ForcePassword -eq "N") {
    Write-Host "Existing" -ForegroundColor Green
    Exit
    }
elseif ($ForcePassword -eq "Y") {
    Connect-AzureAD 
        foreach ($ImportCSV1 in $ImportCSV) {
        Set-MsolUserPassword -UserPrincipalName $ImportCSV1.UserPrincipalName -ForceChangePasswordOnly $true -ForceChangePassword $true
    }
        }
       
else {
    if ($ForcePassword -eq "Yes") {
        foreach ($ImportCSV1 in $ImportCSV) {
        Set-MsolUserPassword -UserPrincipalName $ImportCSV1.UserPrincipalName -ForceChangePasswordOnly $true -ForceChangePassword $true
        }
  } 
}

# Revoke User Sessions
Write-Host "Do you want to Revoke User/s Account? " -NoNewline
Write-Host "(No is default): " -ForegroundColor Green -NoNewline
$RevokeSession = Read-Host

# Message Filter Default Input if nothing has been entered
If ([string]::IsNullOrWhiteSpace($RevokeSession))
{
    Write-Host "Existing" -ForegroundColor Green
    $RevokeSession = Exit
}
elseif ($RevokeSession -eq "no") {
    Write-Host "Existing" -ForegroundColor Green
    $RevokeSession = Exit
  }
elseif ($RevokeSession -eq "N") {
    Write-Host "Existing" -ForegroundColor Green
    $RevokeSession = Exit
    }
elseif ($RevokeSession -eq "Y") {
        Connect-AzureAD 
        foreach ($ImportCSV1 in $ImportCSV) {
            Get-AzureADUser -SearchString $ImportCSV1.UserPrincipalName | Revoke-AzureADUserAllRefreshToken
            }
        }
       
else {
    if ($RevokeSession -eq "Yes") {
        Connect-AzureAD 
        foreach ($ImportCSV1 in $ImportCSV) {
            Get-AzureADUser -SearchString $ImportCSV1.UserPrincipalName | Revoke-AzureADUserAllRefreshToken 
            }
        } 
}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
