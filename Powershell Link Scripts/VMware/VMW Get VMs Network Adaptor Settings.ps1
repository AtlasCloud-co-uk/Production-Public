[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/VMW%20Get%20VMs%20Network%20Adaptor%20Settings.ps1
Invoke-Expression $($ScriptFromGitHub.Content)