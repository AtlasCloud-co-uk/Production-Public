﻿Remove-Module AzureAD -ErrorAction SilentlyContinue
Install-Module -Name AzureADPreview -AllowClobber
Import-Module AzureADPreview
Connect-AzureAD
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-All-Company-Owned-Devices" -Description "All Company Owned Devices" -MailEnabled $False -MailNickName "CompanyDevices" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Company"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-All-Personal-Owned-Device" -Description "All Personal Owned Devices" -MailEnabled $False -MailNickName "PersonalDevice" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Personal"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-Windows-Personal" -Description "All Personal Windows Devices" -MailEnabled $False -MailNickName "WindowsPersonal" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Personal"") and (device.deviceOSType -contains ""Windows"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-Windows-Corp" -Description "All Company Windows Devices" -MailEnabled $False -MailNickName "WindowsCorp" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Company"") and (device.deviceOSType -contains ""Windows"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-Android-Personal" -Description "All Personal Android Devices" -MailEnabled $False -MailNickName "AndroidPersonal" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Personal"") and (device.deviceOSType -contains ""Android"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-Android-Corp" -Description "All Company Android Devices" -MailEnabled $False -MailNickName "AndroidCorp" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOwnership -eq ""Company"") and (device.deviceOSType -contains ""Android"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-iOS-Personal" -Description "All iPhone iPad Personal Devices" -MailEnabled $False -MailNickName "iOSPersonal" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -contains ""iPhone"" -or device.deviceOSType -contains ""iPad"") -and (device.deviceOwnership -contains ""Personal"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-iOS-Corp" -Description "All iPhone iPad Company Devices" -MailEnabled $False -MailNickName "iOSCorp" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -contains ""iPhone"" -or device.deviceOSType -contains ""iPad"") -and (device.deviceOwnership -contains ""Company"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-MacOS-Personal" -Description "All MacOS Personal Devices" -MailEnabled $False -MailNickName "MacOSPersonal" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -contains ""OSX"" -or device.deviceOSType -contains ""macOS"" -or device.deviceOSType -contains ""MacMDM"") -and (device.deviceOwnership -contains ""Personal"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-MacOS-Corp" -Description "All MacOS Company Devices" -MailEnabled $False -MailNickName "MacOSCorp" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -contains ""OSX"" -or device.deviceOSType -contains ""macOS"" -or device.deviceOSType -contains ""MacMDM"") -and (device.deviceOwnership -contains ""Company"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-DEVICE-AutoPilot" -Description "AutoPilot Group" -MailEnabled $False -MailNickName "AutoPilot" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.devicePhysicalIDs -any (_ -contains ""[ZTDid]""))" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-USER-INT" -Description "All Intune Users" -MailEnabled $False -MailNickName "IntuneUser" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(user.userType -ne ""Guest"")" -membershipRuleProcessingState "On"
New-AzureADMSGroup -DisplayName "AZ-SEC-ALL-Windows" -Description "All Windows Devices" -MailEnabled $False -MailNickName "AllWinDev" -SecurityEnabled $True -GroupTypes "DynamicMembership" -membershipRule "(device.deviceOSType -startsWith ""Windows"") or (device.devicePhysicalIDs -any (_ -contains ""[ZTDID]""))" -membershipRuleProcessingState "On"
