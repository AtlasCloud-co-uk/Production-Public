# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -PassThru
Write-Host "Computer: " $ComputerSelect.Name
Write-Host "----------"
Write-Host ""


ForEach ($ADC in $ComputerSelect) 
{
  $CrashNum = $null
  Try 
  {
    $CrashNum = Get-WinEvent -ComputerName $ADC.Name -LogName System -FilterXPath "*[System[EventID=6008 and TimeCreated[timediff(@SystemTime) <= 36000000]] ]" -EA SilentlyContinue | Measure
  }

  Catch
  {
    Write-Host $ADC.Name " - " $_.Exception.Message
  }

  Finally
  {
    If (($CrashNum -ne $null) -and ($CrashNum.Count -eq 0)) { Write-Host $CrashNum.Count $ADC.Name -foregroundcolor Green}
    If (($CrashNum -ne $null) -and ($CrashNum.Count -ne 0)) { Write-Host $CrashNum.Count $ADC.Name -foregroundcolor Red}
  }

}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
