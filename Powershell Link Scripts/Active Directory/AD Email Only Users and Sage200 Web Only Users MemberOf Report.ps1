[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Email%20Only%20Users%20and%20Sage200%20Web%20Only%20Users%20MemberOf%20Report.ps1
Invoke-Expression $($ScriptFromGitHub.Content)