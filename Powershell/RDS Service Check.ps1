# Import Selected Environment
$RDSServerImportENV = Import-Csv -Path "C:\Powershell Scripts\CSV\SelectENV.csv"

# Select Environment
$RDSEnvSelect = $RDSServerImportENV | Out-gridview -Title "Select Environment and Click OK" -PassThru


# Import Selected Server List per Environment
If($RDSEnvSelect.Select -match '1'){
$RDSServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\RDServerPUL.csv"
}
Else{
$RDSServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\RDServerSUN.csv"
}

# Get Server Details
$Serverlist = $RDSServerImport.Server
foreach ($Server in $Serverlist)
    {
    Get-ADComputer $Server | Select Name
       Get-Service -ComputerName $Server | Where {($_.DisplayName -like "*Remote Desktop*") -and ($_.DisplayName -notlike "*Hyper-V*")} | Format-Table

    }

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue