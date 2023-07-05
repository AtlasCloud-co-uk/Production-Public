# Get a list of all VHD and VHDX files, sizes, and locations
# Might come in handy in future --mpurvis

$ServerPaths = @"
\\pul-fsl02\e$
\\pul-fsl02\f$
\\pul-fsl03\e$
\\pul-fsl03\f$
"@

$ServerPaths = $ServerPaths -split "`r?`n" | Where-Object { $_.Trim() -ne '' }


$FileTypes = @("*.vhd", "*.vhdx")  # Add any other file types you want to include

$Results = foreach ($ServerPath in $ServerPaths) {
    $Files = Get-ChildItem -Path $ServerPath -Recurse -File -Include $FileTypes

    foreach ($File in $Files) {
        $FilePath = $File.FullName
        $FileSizeGB = $File.Length / 1GB
	$FileSizeGB = [Math]::Round($FileSizeGB, 2)
        $FileName = $File.Name

        [PSCustomObject]@{
            FilePath = $FilePath
            FileSizeGB = $FileSizeGB
            FileName = $FileName
        }
    }
}

$Results | Select-Object FilePath, FileSizeGB, FileName | Sort-Object FileSizeGB -Descending | Out-GridView
