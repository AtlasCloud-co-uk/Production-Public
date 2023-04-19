[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20OU%20Set%20All%20To%20Not%20Change%20Password%20On%20Next%20Logon.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
