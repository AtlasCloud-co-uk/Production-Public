[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/UTL%20Start%20SCCM%20Prep%20on%20Remote%20Computer.ps1
Invoke-Expression $($ScriptFromGitHub.Content)