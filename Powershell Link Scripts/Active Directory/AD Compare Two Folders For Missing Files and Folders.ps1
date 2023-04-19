[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Compare%20Two%20Folders%20For%20Missing%20Files%20and%20Folders.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
