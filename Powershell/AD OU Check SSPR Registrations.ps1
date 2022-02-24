#Get-AdUser -Properties ssprq -filter {ssprq -like '*'} | FT Name,SamAccountName

$ADUsers = Get-AdUser -Properties ssprq -filter {ssprq -like '*'}

foreach ($ADUser in $ADUsers)
    {
    Write-Host $ADUser.Name
    }