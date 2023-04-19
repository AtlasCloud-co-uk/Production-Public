REM The following is required to be performed before a golden image for the MECM/SCCM agent which forces a full sync on reboot, the shortcut is Ran As Administrator

net stop CCMExec
del %Windir%\SMSCFG.INI
powershell.exe -Command "Remove-Item -Path HKLM:\Software\Microsoft\SystemCertificates\SMS\Certificates\* -Force"
wmic /namespace:\\root\ccm\invagt path inventoryActionStatus where InventoryActionID="{00000000-0000-0000-0000-000000000001}" DELETE /NOINTERACTIVE
