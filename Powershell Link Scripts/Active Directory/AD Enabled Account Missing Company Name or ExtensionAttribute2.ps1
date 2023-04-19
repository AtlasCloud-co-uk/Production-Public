[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Enabled%20Account%20Missing%20Company%20Name%20or%20ExtensionAttribute2.ps1
Invoke-Expression $($ScriptFromGitHub.Content)