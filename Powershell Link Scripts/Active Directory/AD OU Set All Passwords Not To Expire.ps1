[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20OU%20Set%20All%20Passwords%20Not%20To%20Expire.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
