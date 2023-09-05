# around 20 mins to run
function Get-SqlEditionInfo {
    $regKeyPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL"
    if (Test-Path -Path $regKeyPath) {
        # Get the first Sql instance path
        $keyProperties = Get-ItemProperty -Path $regKeyPath
        $firstSqlInstance = $keyProperties.PSObject.Properties | Where-Object { $_.Name -ne "PS*" -and $_.Value.GetType() -eq [String] } | Select-Object -First 1
        $instanceName = $firstSqlInstance.Value
        $regKeyPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instanceName\Setup"
        $edition = (Get-ItemProperty -Path $regKeyPath).Edition
        $edition
    }
    else {
        $edition = ""
    }
}

$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelection = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -OutputMode Multiple

$results = @()

foreach($Computer in $ComputerSelection) {
    $ComputerName = $Computer.Name
    try {
        $Edition = Invoke-Command -ComputerName $ComputerName -ScriptBlock ${function:Get-SqlEditionInfo} -ErrorAction SilentlyContinue
    } catch {}

    $tmpCollector = [PSCustomObject]@{
        ComputerName = $ComputerName
        Edition = $Edition
    }

    $results += $tmpCollector
}

$results

