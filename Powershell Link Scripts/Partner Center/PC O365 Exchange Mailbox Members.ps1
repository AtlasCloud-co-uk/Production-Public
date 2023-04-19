[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/PC%20O365%20Exchange%20Mailbox%20Members.ps1
Invoke-Expression $($ScriptFromGitHub.Content)
