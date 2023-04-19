[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20User%20Count%20by%20Company%20and%20Extension%20Report.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
