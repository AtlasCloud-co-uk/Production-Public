# Folder Name Variable
$Folder = 'c:\hwid'

#Message OutPut
"Test to see if folder [$Folder] exists"

#Test the folder path exisit if so create the file, if not create the folder then create the file.
if (Test-Path -Path $Folder) {
# Change expection policy to aloow the report package to install
set-executionpolicy -executionpolicy bypass -force
# Get the NuGet package
install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$False
# Install the script from the package
install-script -name get-windowsautopilotinfo -force -Confirm:$False
# Set a environmental variable to the install path
$env:Path += ";c:\program files\windowspowershell\scripts"
# Change drive location
cd c:\HWID
# Create variable to get the device serial number
$GetSerial=Get-WmiObject win32_bios -Property SerialNumber | Select-Object SerialNumber
# Create a variable to output just the serial number
$Serialb=$GetSerial.SerialNumber
# Create a variable for the output for the below script that combineds the name "device" and serial number
$Export=".\Device_$Serialb.csv"
# Run the script and Output
Get-WindowsAutoPilotInfo.ps1 -output $export
} else {
# Create a the new folder
New-Item -ItemType Directory -Path "c:\" -Name "HWID"
# Change expection policy to aloow the report package to install
set-executionpolicy -executionpolicy bypass -force
# Get the NuGet package
install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$False
# Install the script from the package
install-script -name get-windowsautopilotinfo -force -Confirm:$False
# Set a environmental variable to the install path
$env:Path += ";c:\program files\windowspowershell\scripts"
# Change drive location
cd c:\HWID
# Create variable to get the device serial number
$GetSerial=Get-WmiObject win32_bios -Property SerialNumber | Select-Object SerialNumber
# Create a variable to output just the serial number
$Serialb=$GetSerial.SerialNumber
# Create a variable for the output for the below script that combineds the name "device" and serial number
$Export=".\Device_$Serialb.csv"
# Run the script and Output
Get-WindowsAutoPilotInfo.ps1 -output $export
}
