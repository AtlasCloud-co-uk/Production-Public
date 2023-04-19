[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/O365%20Change%20Password%20on%20Next%20Logon%20with%20Select%20Users
Invoke-Expression $($ScriptFromGitHub.Content)