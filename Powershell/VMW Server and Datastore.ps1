# Start Get-PSSession
Get-PSSession | Remove-PSSession


# Imports the Server names
$VSphereServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\VMServers.csv"

# OutPut CSV to GridView
$VSphereSelect = $VSphereServerImport | Out-gridview -Title "Select VSphere Server and Click OK" -PassThru

# Connet to VMWare
Import-Module vmware.vimautomation.core
Connect-VIServer $VSphereSelect.Server

# Create a table

$tbl = New-Object System.Data.DataTable "VMW Data"
$col1 = New-Object System.Data.DataColumn Server
$col2 = New-Object System.Data.DataColumn Datastore
$tbl.Columns.Add($col1)
$tbl.Columns.Add($col2)

 
# Gets the information and outputs to Gridview

$VMs = Get-VM | Sort-Object Name
$Output = 
foreach ($VM in $VMs) {

    $Datastore = Get-VM -Name $VM | Get-Datastore | Select-Object name
    
    $row = $tbl.NewRow()
    $row.Server = $VM.Name
    $row.Datastore = $Datastore.Name
    $tbl.Rows.Add($row)
}

# OutPut to Grid View
$tbl | out-gridview -Title "VSphere Server and DataStore"

#Select if want to save as CSV

if ($tbl)
{
    $Export = Read-Host -Prompt "Would you like to save as a CSV? Y/N (Default is N)"
        if ($Export -eq 'y')
        {
        $ExportLocation = Read-Host -Prompt "Provide the location (Example: c:\)"
            if ($ExportLocation)
            {
            $ExportFileName = Read-Host -Prompt "Provide the filename (Example: CSVTest.csv) if the file already exisits you will need to re-run the script"
                if ($ExportFileName -like '*.csv')
                {
                $ExportCombined = -join($ExportLocation,$ExportFileName)
                    if (test-path $ExportCombined)
                       {
                       Write-Host "File Already Exisits" -ForegroundColor Red 
                       }
                       Else
                       {
                       $Output | Out-File -FilePath $ExportCombined
                       $ExportCombined
                       Remove-Variable * -ErrorAction SilentlyContinue
                       Write-Host "File created" -ForegroundColor Green
                       }         
                }
                Else
                {
                Remove-Variable * -ErrorAction SilentlyContinue
                Write-Host "No Filename Details Entered" -ForegroundColor Red
                }
            }
            Else
            {
            Remove-Variable * -ErrorAction SilentlyContinue
            Write-Host "No Path Entered" -ForegroundColor Red
                        }
        }
     Else
     {
    # Clears the Variables, this stops any issue with the variables bring back any previous held information
    Remove-Variable * -ErrorAction SilentlyContinue
    Write-Host "No CSV required" -ForegroundColor Green
    }
}
