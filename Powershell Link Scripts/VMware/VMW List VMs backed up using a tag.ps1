[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest -UseBasicParsing -Uri https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/VMW%20List%20VMs%20backed%20up%20using%20a%20tag.ps1
Invoke-Expression $($ScriptFromGitHub.Content)