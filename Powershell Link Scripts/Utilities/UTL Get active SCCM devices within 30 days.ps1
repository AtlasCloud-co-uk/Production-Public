[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/UTL%20Get%20active%20SCCM%20devices%20within%2030%20days.ps1
Invoke-Expression $($ScriptFromGitHub.Content)