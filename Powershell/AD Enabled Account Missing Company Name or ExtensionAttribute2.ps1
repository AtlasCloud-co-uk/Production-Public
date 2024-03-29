# AD See Enabled Account where Company Name or extensionAttribute2 is missing.
Get-ADUser -SearchBase "DC=corp,DC=atlascloud,DC=net" -Filter * -Properties Company,extensionAttribute2  | Where {($_.Enabled -eq 1) -and ($_.Company -eq $null) -or ($_.extensionAttribute2 -eq $null)} | Sort-Object Company | Select-Object -Property Name,Company,extensionAttribute2
