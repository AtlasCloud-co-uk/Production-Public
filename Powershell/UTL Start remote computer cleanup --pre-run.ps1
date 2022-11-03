function New-Cleanup {
	$CleanupScriptPath = "C:\PowerShell Scripts\Utilities\UTL Start remote computer cleanup.ps1"
	$CleanmgrTimeoutOption = "5" # default value
	$DismTimeoutOption = "5" # default value
	$DismAdvancedOption = 0 # default value

	function Start-Cleanup {
		$Global:RunCommand = Get-CurrentRunCommand # Evaluate current run command
		Write-Host "Running '$RunCommand'"
		if ($RunAgainstLocalPC){
			& "$CleanupScriptPath" -CleanmgrTimeout $CleanmgrTimeoutOption -DismTimeout $DismTimeoutOption -DismAdvanced:$DismAdvancedOption
		} else {
			Invoke-Command -FilePath "$CleanupScriptPath" -ComputerName $RemoteComputerName -Credential $RemoteCredentials -ArgumentList $CleanmgrTimeoutOption, $DismTimeoutOption, $DismAdvancedOption
		}
	}

	function Get-CurrentRunCommand { # Just cosmetic
		if ($RunAgainstLocalPC){
			$Command = "& '$CleanupScriptPath' -CleanmgrTimeout $CleanmgrTimeoutOption -DismTimeout $DismTimeoutOption -DismAdvanced:$DismAdvancedOption"
		} else {
			$Command = "Invoke-Command -FilePath '$CleanupScriptPath' -ComputerName $RemoteComputerName -Credential `$RemoteCredentials -ArgumentList `$CleanmgrTimeoutOption, `$DismTimeoutOption, `$DismAdvancedOption"
		}
		return $Command
	}

	function Show-AdvancedMenu {
		$Global:RunCommand = Get-CurrentRunCommand # Evaluate current run command
		# Advanced options -- menu
		$ScriptSetup04 = @"
What do you want to change?
[1] Cleanmgr timeout period -- Currently set to $CleanmgrTimeoutOption mins
[2] Dism timeout period -- Currently set to $DismTimeoutOption mins
[3] Advanced Dism cleanup -- Currently set to $([bool]$DismAdvancedOption)
[4] Run script below

Built command:`t'$Global:RunCommand'

Type a number and press enter
"@

		$DismAdvancedOptionPrompt = @"
Info
- If disabled:	Frees up less space; safer
- If enabled:	Frees up more space; currently installed updates can't be removed

[1] Disabled -- default
[2] Enabled

Type a number and press enter
"@
		$ScriptSetup04Response = Read-Host -Prompt $ScriptSetup04
		switch ($ScriptSetup04Response) {
			"1" {	$CleanmgrTimeoutOption = Read-Host -Prompt "`nEnter the new Cleanmgr timeout value (in mins)"; cls; Show-AdvancedMenu }
			"2" {	$DismTimeoutOption = Read-Host -Prompt "`nEnter the new Dism timeout value (in mins)"; cls; Show-AdvancedMenu }
			"3" {	cls; $DismAdvancedOption = Read-Host -Prompt $DismAdvancedOptionPrompt
					switch ($DismAdvancedOption) {
						"1" { $DismAdvancedOption = 0 }
						"2" { $DismAdvancedOption = 1 }
						Default { $DismAdvancedOption = 0 }
					}
					cls
					Show-AdvancedMenu}
			"4" {	cls; Start-Cleanup }
			Default {Write-Host "One of the listed numbers was not entered";break}
		}
	}

	function Show-AskIfLocalOrRemotePC {

		# Run script locally or remotely?
		$AskIfLocalOrRemotePC = @"
How do you want to run this script?
[1] Locally on this computer
[2] Against a remote computer

Type a number and press enter
"@
		cls
		$AskIfLocalOrRemotePCResponse = Read-Host -Prompt $AskIfLocalOrRemotePC
		switch ($AskIfLocalOrRemotePCResponse) {
			"1" { $Global:RunAgainstLocalPC = $true; cls }
			"2" { $Global:RunAgainstLocalPC = $false; cls }
			Default {Write-Host "One of the listed numbers was not entered";exit}
		}

		if ($AskIfLocalOrRemotePCResponse -eq "2"){ # remote computer
			$Global:RemoteComputerName = Read-Host -Prompt "Enter the remote computer name"
			cls

			# Do we need to specify alternative credentials
			$ScriptSetup02 = @"
Do you need to specify alternative credentials to run the script as?
[1] No -- connect with $Global:RemoteComputerName\Administrator
[2] Yes

Type a number and press enter
"@

		$ScriptSetup02Response = Read-Host -Prompt $ScriptSetup02
			switch ($ScriptSetup02Response) {
				"1" { $Global:RemoteCredentials = Get-Credential -UserName "$RemoteComputerName\Administrator" -Message "Enter the local administrator password for $Global:RemoteComputerName"; cls }
				"2" { $Global:RemoteCredentials = Get-Credential; cls }
				Default {Write-Host "One of the listed numbers was not entered";break}
			}
		}
		
	}

	function Show-AskIfAdvancedMenuNeeded {
		$Global:RunCommand = Get-CurrentRunCommand # Evaluate current run command
		# Advanced options?
		$AskIfAdvancedMenuNeeded = @"
Do you need to specify advanced options?
[1] No -- defaults
[2] Yes

Type a number and press enter
"@
		$AskIfAdvancedMenuNeededResponse = Read-Host -Prompt $AskIfAdvancedMenuNeeded
		switch ($AskIfAdvancedMenuNeededResponse) {
			"1" { cls; Start-Cleanup }
			"2" { cls; Show-AdvancedMenu }
			Default {Write-Host "One of the listed numbers was not entered";break}
		}
	}
	Show-AskIfLocalOrRemotePC
	Show-AskIfAdvancedMenuNeeded


}



New-Cleanup






