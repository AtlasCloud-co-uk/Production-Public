# Gets a list of Computers
$ComputerList = Get-ADComputer -Filter * -Properties Name,DistinguishedName | Sort-Object | Select-Object -Property Name,DistinguishedName
$ComputerSelect = $ComputerList | Out-GridView -Title "Select Computer Name and Click OK" -PassThru
Write-Host "Computer: " $ComputerSelect.Name
Write-Host "----------"
Write-Host ""

ForEach ($ADC in $ComputerSelect) 

{
  $WMIMemoryDetail = $null
  Try 
  {
    $WMIMemoryDetail = Get-WmiObject Win32_PhysicalMemory -ComputerName $ADC.Name -EA SilentlyContinue
    $WMIPageFileDetail = Get-WmiObject Win32_PageFileUsage -ComputerName $ADC.Name -EA SilentlyContinue
  }

  Catch
  {
    Write-Host $ADC.Name " - " $_.Exception.Message
  }

  Finally
  {
    If (($WMIMemoryDetail -ne $null) -and ($WMIPageFileDetail -ne $nul)) 
    { 
      $WMIMemoryGB = $WMIMemoryDetail | Measure-Object -Property Capacity -Sum | %{[Math]::Round(($_.Sum / 1GB),2)}
      $WMIPageFileGB = $WMIPageFileDetail | Measure-Object -Property AllocatedBaseSize -Sum | %{[Math]::Round(($_.Sum / 1KB),2)}
      $WMIPageFilePeakGB = $WMIPageFileDetail | Measure-Object -Property PeakUsage -Sum | %{[Math]::Round(($_.Sum / 1KB),2)}
      
      Write-Host $ADC.Name " " $WMIMemoryGB"GB" " " $WMIPageFileGB"GB" " " $WMIPageFilePeakGB"GB"
  }
}
}

# Clears the Variables, this stops any issue with the variables bring back any previous held information
Remove-Variable * -ErrorAction SilentlyContinue
