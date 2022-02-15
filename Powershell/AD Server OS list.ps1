# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties  Name,Operatingsystem, OperatingSystemVersion, OperatingSystemServicePack,IPv4Address | Sort-Object -Property Operatingsystem | Select-Object -Property Name,Operatingsystem, OperatingSystemVersion, OperatingSystemServicePack, IPv4Address
$ComputerSelect = $ComputerList | Out-GridView -Title "Sorted By Operation System"

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
