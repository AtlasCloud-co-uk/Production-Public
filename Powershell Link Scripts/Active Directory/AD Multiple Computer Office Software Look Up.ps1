[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Multiple%20Computer%20Office%20Software%20Look%20Up.ps1
Invoke-Expression $($ScriptFromGitHub.Content)