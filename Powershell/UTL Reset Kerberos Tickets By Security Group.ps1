Add-Type -AssemblyName PresentationFramework

Import-Module ActiveDirectory

[System.Windows.MessageBox]::Show("Select the security groups containing computer objects to re-evaluate their AD security group memberships.`nThis script will skip non-computer objects within the security groups.", "Information", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

$selectedGroups = Get-ADGroup -Filter {GroupCategory -eq 'Security'} | 
    Select-Object -Property Name, DistinguishedName |
    Out-GridView -Title "Select Security Groups" -OutputMode Multiple

$computerObjects = New-Object System.Collections.Generic.HashSet[string]

foreach ($group in $selectedGroups) {
    $computersInGroup = Get-ADGroupMember -Identity $group.DistinguishedName -Recursive |
        Where-Object { $_.objectClass -eq 'computer' } |
        ForEach-Object { $_.Name }

    foreach ($computer in $computersInGroup) {
        $computerObjects.Add($computer) | Out-Null
    }
}

foreach ($computer in $computerObjects) {
    Write-Host "Re-evaluating security group membership for $computer..."
    Invoke-Command -ComputerName $computer -AsJob -ScriptBlock {
        klist.exe -li 0x3e7 purge
        gpupdate /force
    }
}

$runningJobs = Get-Job | Where-Object { $_.State -eq "Running" }

while ($runningJobs.Count -gt 0) {
    Get-Job | Format-Table -AutoSize
    Start-Sleep -Seconds 5
    cls
    $runningJobs = Get-Job | Where-Object { $_.State -eq "Running" }
}

Read-Host -Prompt "Press return to close."