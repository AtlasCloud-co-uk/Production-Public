[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/UTL%20New%20Azure%20VPN%20Gateway%20Certificate%20Setup.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
