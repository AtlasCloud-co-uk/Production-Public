﻿[System.Net.WebRequest]::DefaultWebProxy.Credentials =[System.Net.CredentialCache]::DefaultNetworkCredentials
$ScriptFromGitHub = Invoke-WebRequest https://raw.githubusercontent.com/AtlasCloud-co-uk/Production-Public/main/Powershell/AD%20Multiple%20Computers%20Local%20Administrator%20Group%20Members.ps1
Invoke-Expression $($ScriptFromGitHub.Content)