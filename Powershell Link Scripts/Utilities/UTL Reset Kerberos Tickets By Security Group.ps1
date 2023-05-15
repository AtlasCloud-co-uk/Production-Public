[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/UTL%20Reset%20Kerberos%20Tickets%20By%20Security%20Group.ps1 -UseBasicParsing
Invoke-Expression $($ScriptFromGitHub.Content)