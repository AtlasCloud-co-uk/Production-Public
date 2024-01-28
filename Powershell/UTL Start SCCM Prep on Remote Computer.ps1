function SCCMPrepRemoteComputer
{
    param(
        [Parameter(Position=0,Mandatory=$false,ValueFromPipeline)]
        [string]
        $SenderUsername
    )
    #region Hardcoded variables
        $eventLogName = "SCCM-Pre-shutdown-Script"
        $registryKeyPath = "HKLM:\SYSTEM\ControlSet001\Services\EventLog\$eventLogName"
        $registryMultiStringName = "Sources"
        $eventSourceName = "SCCM-Script"
    #endregion

    #region Set up event viewer source if not created
        # Check if the registry key exists
        if (-not (Test-Path $registryKeyPath)) {
            # Create registry path
            New-Item -Path $registryKeyPath -Force
            Set-ItemProperty -Path $registryKeyPath -Name $registryMultiStringName -Value $eventSourceName -Type MultiString
        }

        # Check if the event source has been 
        if ([System.Diagnostics.EventLog]::SourceExists($eventSourceName) -eq $false) {
            [System.Diagnostics.EventLog]::CreateEventSource($eventSourceName, $eventLogName)
        }
    #endregion

    #region SCCM PREP STEPS SHOULD BE WITHIN THIS SECTION HERE
        try {
                Stop-Service CCMExec -Verbose
                Remove-Item -Path "$env:Windir\SMSCFG.INI" -Force -Verbose -ErrorAction SilentlyContinue
                Remove-Item -Path "HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\*" -Force -Verbose -ErrorAction SilentlyContinue
                Write-Output "Resetting GUID."
                cmd.exe /c 'wmic /namespace:\\root\ccm\invagt path inventoryActionStatus where InventoryActionID="{00000000-0000-0000-0000-000000000001}" DELETE /NOINTERACTIVE'
                Write-Output "Setting delayed start for CCMExec"
                $regKey = "HKLM:\SYSTEM\CurrentControlSet\Services\CCMExec"
                $startType = (Get-ItemProperty $regKey).Start
                $delayedAutoStart = (Get-ItemProperty $regKey).DelayedAutoStart
                if (($startType -ne "2") -or ($delayedAutoStart -ne "1")){ # Set the service to delayed automatic start
                    Set-ItemProperty $regKey -Name Start -Value 2
                    Set-ItemProperty $regKey -Name DelayedAutoStart -Value 1
                }

                Write-Host "Pre-snapshot actions have now completed. Shutdown the VM and then snapshot." -ForegroundColor Green
            }
            catch {
                Write-Host "Oops! An error occurred while running the script. Please check the error message below:" -ForegroundColor Red
                Write-Host $_.Exception.Message -ForegroundColor Red
            }
    #endregion

    Write-EventLog -LogName $eventLogName -Source $eventSourceName -EventID 1 -EntryType Information -Message "The SCCM pre-shutdown script has been executed at this time. Command executed by $SenderUsername."
    
    # OS graceful shutdown if needed
    # shutdown.exe /s /t 0
}


#region Prepping execution
    $UsernameToSend = ($env:USERDOMAIN) + '\' + ($env:USERNAME)

    $ComputerList = Get-ADComputer -Filter {Name -like "*XX"} -Properties Name, DistinguishedName | Sort-Object | Select-Object -Property Name, DistinguishedName
    $ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Single

    if ($null -eq $ComputerSelect){
        Write-Output "Computer not selected."
        exit
    }

    $creds = Get-Credential -UserName ($ComputerSelect.Name + "\" + "Administrator") -Message "Enter the remote administrator password on the computer."

    Invoke-Command -ComputerName $ComputerSelect.Name -Credential $creds -ScriptBlock ${function:SCCMPrepRemoteComputer} -ArgumentList $UsernameToSend
#endregion
