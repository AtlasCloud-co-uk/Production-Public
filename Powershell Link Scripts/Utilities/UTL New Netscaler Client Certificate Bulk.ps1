[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/UTL%20New%20Netscaler%20Client%20Certificate%20Bulk.ps1 -UseBasicParsing
Invoke-Expression $($ScriptFromGitHub.Content)