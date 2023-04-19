[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/VMW%20Server%20CPU%20Memory%20and%20HDD.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
