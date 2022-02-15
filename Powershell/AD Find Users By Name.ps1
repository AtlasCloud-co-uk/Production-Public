# Obtain user name

$User = Read-Host -Prompt "Name (Example: john | john glen | *glen)" 

#Find the user and display the 
$ListADUSers = get-aduser -Filter "Name -like '$User*'" -Properties Name,LastLogonDate,Description,Created,CanonicalName | select-object -Property name,enabled,lastlogondate,CanonicalName

# If Statement used to Display a message if no user is found
if ($ListADUsers)
{
    Write-OutPut $ListADUsers | Out-host
       
 }
Else
{
Write-Host "No User Found" -ForegroundColor Red
}

#CSV File Export Prompts
if ($ListADUsers)
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
                       $ListADUSers | Export-CSV -Path $ExportCombined
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
