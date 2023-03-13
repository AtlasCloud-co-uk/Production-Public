<#
    This script will check all VMs for tags using the "Veeam Backup Job Name" category in vCenter which correspond to actual Veeam jobs.
    The user is prompted for:
    1. Showing the output in an Out-GridView window
    2. Specifying where to export a csv if they so choose
#>

#############################################################################
#If Powershell is running the 32-bit version on a 64-bit machine, we 
#need to force powershell to run in 64-bit mode .
#############################################################################
if ($env:PROCESSOR_ARCHITEW6432 -eq "AMD64") {
    write-warning "Opening 64-bit powershell....."
    if ($myInvocation.Line) {
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NoProfile $myInvocation.Line
    }else{
        &"$env:WINDIR\sysnative\windowspowershell\v1.0\powershell.exe" -NoProfile -file "$($myInvocation.InvocationName)" $args
    }
exit $lastexitcode
}

Import-Module VMware.VimAutomation.Core

$VSphereServerImport = Import-Csv -Path "C:\Powershell Scripts\CSV\VMServers.csv"
Connect-VIServer $VSphereServerImport.Server

# VM Tag Reporting
$allVMs = Get-View -ViewType Virtualmachine | Sort-Object -Property Name

$metadataCategoryName = "Veeam Backup Job Name"

$result = foreach($vm in $allVMs){

    $tagAssignments = Get-TagAssignment -Entity (Get-VIObjectByVIView -VIView $vm) -Category $metadataCategoryName

    if ($tagAssignments.Count -le 1)
    {   
        $DataCollector = "" | Select-Object VMName,TagName,TagCategory,Description,Notes

        $DataCollector.VMName = $vm.Name
        $DataCollector.TagName = $tagAssignments.Tag.Name
        $DataCollector.TagCategory = $metadataCategoryName
        $DataCollector.Description = $tagAssignments.Tag.Description

        if ($null -eq $DataCollector.TagName) {
            $DataCollector.Notes = "This VM is not backed up by a tag!"
        }

        $DataCollector
    }

    if ($tagAssignments.Count -gt 1)
    {
        foreach ($tagAssignment in $tagAssignments) {
            $DataCollector = "" | Select-Object VMName,TagName,TagCategory,Description,Notes

            $DataCollector.VMName = $vm.Name
            $DataCollector.TagName = $tagAssignment.Tag.Name
            $DataCollector.TagCategory = $metadataCategoryName
            $DataCollector.Description = $tagAssignment.Tag.Description

            $DataCollector
        }
    }    
}

do {
    $option = Read-Host "How do you want to show the output from this script?`n[1] Show the output in a PowerShell window`n[2] Let me export the output to a CSV"
} until ($option -in 1,2)

if ($option -eq 1) {
    $result | Out-GridView
}
elseif ($option -eq 2) {
    Add-Type -AssemblyName System.Windows.Forms
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"
    $saveFileDialog.Title = "Save CSV File"
    if ($saveFileDialog.ShowDialog() -eq "OK") {
        $filePath = $saveFileDialog.FileName
        $result | Export-Csv -Path $filePath -NoTypeInformation
        Write-Host "CSV file saved to: $filePath"
    }
}
