
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [double]
        $CleanmgrTimeout = 5,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [double]
        $DismTimeout = 5,

        [Parameter(Mandatory = $false,ValueFromPipelineByPropertyName)]
        [bool]
        $DismAdvanced = $false
    )

    ## Initialize vars
    $ScriptStartDate = Get-Date
    $ScriptStartTime = Get-Date | Select-Object -ExpandProperty DateTime
    $DaysToDelete = 7
    $CleanmgrWaitTimeInSeconds = ($CleanmgrTimeout * 60)
    $DismWaitTimeInSeconds = ($DismTimeout * 60)
    $VerbosePreference = "Continue"
    $ErrorActionPreference = "SilentlyContinue"


## Check $VerbosePreference variable, and turns on
Function global:Write-Verbose ( [string]$Message ) {
    if ( $VerbosePreference -ne 'SilentlyContinue' ) {
        Write-Host "$Message" -ForegroundColor 'Green'
    }
}

Write-Verbose @" 
################################################################################################################
##                                           Starting cleanup script                                          ##
##                                          Please allow time to run.                                         ##
################################################################################################################

Hostname:`t`t$($env:COMPUTERNAME)

Options:
Cleanmgr timeout:`t$CleanmgrTimeout mins
Dism timeout:`t`t$DismTimeout mins
Dism advanced cleanup:`t$DismAdvanced
`n`n
"@


## Writes a verbose output to the screen for user information
Write-Host "Retrieving current disk percent free for comparison once the script has completed.`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

## Gathers the amount of disk space used before running the script
$Before = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f ( $_.Size / 1gb)}},
@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f ( $_.Freespace / 1gb ) } },
@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize |
    Out-String

## Stops the windows update service so that c:\windows\softwaredistribution can be cleaned up
Get-Service -Name wuauserv | Stop-Service -Force -ErrorAction SilentlyContinue -WarningAction SilentlyContinue

# Sets the SCCM cache size to 1 GB if it exists.
if ( $null -ne (Get-WmiObject -namespace root\ccm\SoftMgmtAgent -class CacheConfig)){
    # if data is returned and sccm cache is configured it will shrink the size to 1024MB.
    $cache = Get-WmiObject -namespace root\ccm\SoftMgmtAgent -class CacheConfig
    $Cache.size = 1024 | Out-Null
    $Cache.Put() | Out-Null
    Restart-Service ccmexec -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
}

## Deletes the contents of windows software distribution.
Get-ChildItem "C:\Windows\SoftwareDistribution\*" -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -recurse -ErrorAction SilentlyContinue
Write-Host "The Contents of Windows SoftwareDistribution have been removed successfully!`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

## Deletes the contents of the Windows Temp folder.
Get-ChildItem "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete)) } | Remove-Item -force -recurse -ErrorAction SilentlyContinue
Write-host "The contents of Windows Temp have been removed successfully!`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black


## Deletes all files and folders in user's Temp folder older then $DaysToDelete
Get-ChildItem "C:\users\*\AppData\Local\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete))} |
    Remove-Item -force -recurse -ErrorAction SilentlyContinue
Write-Host "The contents of `$env:TEMP have been removed successfully!`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

## Removes all files and folders in user's Temporary Internet Files older then $DaysToDelete
Get-ChildItem "C:\users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" `
    -Recurse -Force -ErrorAction SilentlyContinue |
    Where-Object {($_.CreationTime -lt $(Get-Date).AddDays( - $DaysToDelete))} |
    Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
Write-Host "All Temporary Internet Files have been removed successfully!`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

## Removes *.log from C:\windows\CBS
if(Test-Path C:\Windows\logs\CBS\){
Get-ChildItem "C:\Windows\logs\CBS\*.log" -Recurse -Force -ErrorAction SilentlyContinue |
    remove-item -force -recurse -ErrorAction SilentlyContinue
Write-Host "All CBS logs have been removed successfully!`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "C:\Windows\logs\CBS\ does not exist, there is nothing to cleanup.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans IIS Logs older then $DaysToDelete
if (Test-Path C:\inetpub\logs\LogFiles\) {
    Get-ChildItem "C:\inetpub\logs\LogFiles\*" -Recurse -Force -ErrorAction SilentlyContinue |
        Where-Object { ($_.CreationTime -lt $(Get-Date).AddDays(-60)) } | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All IIS Logfiles over $DaysToDelete days old have been removed Successfully!`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
}
else {
    Write-Host "C:\inetpub\logs\LogFiles\ does not exist, there is nothing to cleanup.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes C:\Config.Msi
if (test-path C:\Config.Msi){
    remove-item -Path C:\Config.Msi -force -recurse -ErrorAction SilentlyContinue
    Write-Host "C:\Config.Msi has been removed Successfully!`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

} else {
    Write-Host "C:\Config.Msi does not exist, there is nothing to cleanup.`t`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes c:\Intel
if (test-path c:\Intel){
    remove-item -Path c:\Intel -force -recurse -ErrorAction SilentlyContinue
    Write-Host "C:\Intel temp installer folder has been removed.`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "C:\Intel does not exist, there is nothing to cleanup.`t`t`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes c:\PerfLogs
if (test-path c:\PerfLogs){
    remove-item -Path c:\PerfLogs -force -recurse -ErrorAction SilentlyContinue
    Write-Host "C:\PerfLogs folder has been removed.`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "C:\PerfLogs does not exist, there is nothing to cleanup.`t`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes $env:windir\memory.dmp
if (test-path $env:windir\memory.dmp){
    ## Removes rouge folders
    Write-host "Deleting memdump files`t`t`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    remove-item $env:windir\memory.dmp -force -ErrorAction SilentlyContinue
} else {
    Write-Host "C:\Windows\memory.dmp does not exist, there is nothing to cleanup.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes Windows Error Reporting files
if (test-path C:\ProgramData\Microsoft\Windows\WER){
    Get-ChildItem -Path C:\ProgramData\Microsoft\Windows\WER -Recurse | Remove-Item -force -recurse -ErrorAction SilentlyContinue
        Write-host "Deleting Windows Error Reporting files`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
        Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
    } else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Removes System and User Temp Files - lots of access denied will occur.
## Cleans up c:\windows\temp
if (Test-Path $env:windir\Temp\) {
    Remove-Item -Path "$env:windir\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "C:\Windows\Temp has been cleaned up.`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Windows\Temp does not exist, there is nothing to cleanup.`t`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up minidump
if (Test-Path $env:windir\minidump\) {
    Remove-Item -Path "$env:windir\minidump\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "Minidump has been cleaned up.`t`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "$env:windir\minidump\ does not exist, there is nothing to cleanup.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up prefetch
if (Test-Path $env:windir\Prefetch\) {
    Remove-Item -Path "$env:windir\Prefetch\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "Prefetch folder has been cleaned up.`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "$env:windir\Prefetch\ does not exist, there is nothing to cleanup.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up each users temp folder
if (Test-Path "C:\Users\*\AppData\Local\Temp\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Temp\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local tmp folders have been cleaned up.`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Temp\ does not exist, there is nothing to cleanup.`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up all users windows error reporting
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\WER\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local Windows Error Reporting folders have been cleaned up.`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\ProgramData\Microsoft\Windows\WER does not exist, there is nothing to cleanup.`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up users temporary internet files
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local temporary internet files have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\Temporary Internet Files\ does not exist.`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up Internet Explorer cache
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local IECompatCache folders have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatCache\ does not exist.`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up Internet Explorer cache
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local IECompatUaCache folders have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IECompatUaCache\ does not exist.`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up Internet Explorer download history
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local IEDownloadHistory folders have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\IEDownloadHistory\ does not exist.`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up Internet Cache
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local INetCache folders have been cleaned up.`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCache\ does not exist.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up Internet Cookies
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local INetCookies folders have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Windows\INetCookies\ does not exist.`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Cleans up terminal server cache
if (Test-Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\") {
    Remove-Item -Path "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "All user appdata local Terminal Server caches have been cleaned up.`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
        Write-Host "C:\Users\*\AppData\Local\Microsoft\Terminal Server Client\Cache\ does not exist.`t`t`t" -NoNewline -ForegroundColor DarkGray
        Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

Write-host "Removing System and User Temp Files`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black

## Removes the hidden recycling bin.
if (Test-path 'C:\$Recycle.Bin'){
    Remove-Item 'C:\$Recycle.Bin' -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "System recycle bin has been cleaned up.`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
    Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
} else {
    Write-Host "System recycle bin does not exist, there is nothing to cleanup.`t`t`t`t`t`t" -NoNewline -ForegroundColor DarkGray
    Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
}

## Turns errors back on
$ErrorActionPreference = "Continue"

## Checks the version of PowerShell
## If PowerShell version 4 or below is installed the following will process
if ($PSVersionTable.PSVersion.Major -le 4) {

    ## Empties the recycling bin, the desktop recyling bin
    $Recycler = (New-Object -ComObject Shell.Application).NameSpace(0xa)
    $Recycler.items() | ForEach-Object { 
    ## If PowerShell version 4 or below is installed the following will process
    Remove-Item -Include $_.path -Force -Recurse
    }
} elseif ($PSVersionTable.PSVersion.Major -ge 5) {
    ## If PowerShell version 5 is running on the machine the following will process
    Clear-RecycleBin -DriveLetter C:\ -Force
}

## Starts cleanmgr.exe
Function Start-CleanMGR {
    try {
        # Set the state to running
        Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' | ForEach-Object {
            New-ItemProperty -Path $_.PSPath -Name StateFlags0001 -Value 2 -PropertyType DWord -Force | Out-Null
           }
        Write-Host "Windows Disk Cleanup is running.`t`t`t`t`t`t`t`t`t" -NoNewline -ForegroundColor Green
        Start-Process -FilePath "C:\Windows\system32\cleanmgr.exe" -ArgumentList '/sagerun:1'
        $CleanmgrStartTime = Get-Date
        
        while (Get-Process -Name cleanmgr -ErrorAction SilentlyContinue) {
            foreach($i in (1..$CleanmgrWaitTimeInSeconds)) {
                $percentage = $i / $CleanmgrWaitTimeInSeconds
                $remaining = New-TimeSpan -Seconds ($CleanmgrWaitTimeInSeconds - $i)
                $message = "{0:p0} complete, remaining time {1}" -f $percentage, $remaining
                Write-Progress -Activity $message -PercentComplete ($percentage * 100)
                Start-Sleep 1
                if (-not (Get-Process -Name "cleanmgr"  -ErrorAction SilentlyContinue) ) {
                    break
                }
            }
            if (((Get-Date) - $CleanmgrStartTime).TotalMinutes -ge $CleanmgrTimeout){ # Kill cleanmgr after x mins of running
                Get-Process -Name *cleanmgr* | Stop-Process -Force
                Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor Black
                Write-Host "Cleanmgr ran for $CleanmgrTimeout mins, killed the process in case of hang" -ForegroundColor DarkGray
                break
            }
            if (-not (Get-Process -Name "cleanmgr"  -ErrorAction SilentlyContinue) ) {
                break
            }
        }
            
        # Set the state to has ran
        Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\*' | ForEach-Object {
            New-ItemProperty -Path $_.PSPath -Name StateFlags0001 -Value 1 -PropertyType DWord -Force | Out-Null
           }
        if (((Get-Date) - $CleanmgrStartTime).TotalMinutes -lt $CleanmgrTimeout){
            Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
        }
    }
    catch [System.Exception]{
        Write-host "Cannot locate cleanmgr.exe.`t`t`t`t`t`t`t`t`t`t" -ForegroundColor Red -NoNewline
        Write-host "[ERROR]" -ForegroundColor Red -BackgroundColor Black
    }
}
Start-CleanMGR

function Start-DismCleanup {
    try {
        Write-Host "Dism is cleaning up 'C:\Windows\WinSXS'.`t`t`t`t`t`t`t`t" -ForegroundColor Green -NoNewline

        if ($DismAdvanced){ # if 1
            Start-Process -FilePath dism.exe -ArgumentList '/online /Cleanup-Image /StartComponentCleanup /ResetBase' -WindowStyle Hidden
        }else { # if 0
            Start-Process -FilePath dism.exe -ArgumentList '/online /Cleanup-Image /StartComponentCleanup' -WindowStyle Hidden
        }
        
        $DismStartTime = Get-Date
        while (Get-Process -Name Dism -ErrorAction SilentlyContinue) {
            foreach($i in (1..$DismWaitTimeInSeconds)) {
                $percentage = $i / $DismWaitTimeInSeconds
                $remaining = New-TimeSpan -Seconds ($DismWaitTimeInSeconds - $i)
                $message = "{0:p0} complete, remaining time {1}" -f $percentage, $remaining
                Write-Progress -Activity $message -PercentComplete ($percentage * 100)
                Start-Sleep 1
                if (-not (Get-Process -Name "dism" -ErrorAction SilentlyContinue) ) {
                    break
                }
            }
            if (((Get-Date) - $DismStartTime).TotalMinutes -ge $DismTimeout){ # Kill dism after x mins of running
                Get-Process -Name *dism* | Stop-Process -Force
                Write-host "[INFO]" -ForegroundColor DarkGray -BackgroundColor black
                Write-Host "Dism ran for $DismTimeout mins, killed the process in case of hang" -ForegroundColor DarkGray
                break
            }
            if (-not (Get-Process -Name "dism" -ErrorAction SilentlyContinue) ) {
                break
            }
        }
        if (((Get-Date) - $DismStartTime).TotalMinutes -lt $DismTimeout){
            Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
        }
    }
    catch [System.Exception]{
        Write-host "Cannot locate dism.exe! Skipping...`t`t`t`t`t`t`t`t`t" -ForegroundColor Red -NoNewline
        Write-host "[ERROR]" -ForegroundColor Red -BackgroundColor black
    }
}
Start-DismCleanup

## gathers disk usage after running the cleanup cmdlets.
$After = Get-WmiObject Win32_LogicalDisk | Where-Object { $_.DriveType -eq "3" } | Select-Object SystemName,
@{ Name = "Drive" ; Expression = { ( $_.DeviceID ) } },
@{ Name = "Size (GB)" ; Expression = {"{0:N1}" -f ( $_.Size / 1gb)}},
@{ Name = "FreeSpace (GB)" ; Expression = {"{0:N1}" -f ( $_.Freespace / 1gb ) } },
@{ Name = "PercentFree" ; Expression = {"{0:P1}" -f ( $_.FreeSpace / $_.Size ) } } |
    Format-Table -AutoSize | Out-String

## Restarts wuauserv
Get-Service -Name wuauserv | Start-Service -ErrorAction SilentlyContinue

## Stop timer
$ScriptEndTime = (Get-Date)

## Calculate amount of seconds your code takes to complete.
Write-Verbose "`nElapsed Time: $(($ScriptEndTime - $ScriptStartDate).totalseconds) seconds`n`n"
Write-Verbose "########################--Results--########################`n`n"

Write-Host "Hostname:`t`t$($env:COMPUTERNAME)" -ForegroundColor Green
Write-Host "Script start time:`t$ScriptStartTime" -ForegroundColor Green
Write-Host ("Script end time:`t" + (Get-Date | Select-Object -ExpandProperty DateTime) + "`n") -ForegroundColor Green

## Pre-cleanup size
Write-Verbose "Before: $Before"

## Post-cleanup size
Write-Verbose "After: $After"

Write-Verbose "###########################################################`n"

Write-Host "This script can be run again, and again to free up more space." -ForegroundColor Green
Write-Host "Script finished`t`t`t`t`t`t`t`t`t`t`t`t" -ForegroundColor Green -NoNewline
Write-Host "[DONE]" -ForegroundColor Green -BackgroundColor Black
Write-Host "`n"


