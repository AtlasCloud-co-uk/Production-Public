[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/VMW%20Server%20and%20Datastore.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
