[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/VMW%20List%20Snapshots.ps1
Invoke-Expression $($ScriptFromGitHub.Content)