[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Event%20Viewer%20Search%20-%20Grid-View%20Inputs.ps1
Invoke-Expression $($ScriptFromGitHub.Content)