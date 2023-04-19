[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Computer%20NTFS%20Permission%20on%20Shared%20Folders.ps1
Invoke-Expression $($ScriptFromGitHub.Content)