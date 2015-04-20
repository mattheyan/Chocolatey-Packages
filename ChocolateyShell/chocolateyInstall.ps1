try {
	$libDir = Split-Path $MyInvocation.MyCommand.Path -Parent

	$powershellPath = (Get-Command 'powershell.exe').Path

	# Taken from Chocolatey:Install-ChocolateyDesktopLink
	# https://github.com/chocolatey/chocolatey/blob/master/src/helpers/functions/Install-ChocolateyDesktopLink.ps1

	$inputTempFile = [System.IO.Path]::GetTempFileName() + '.lnk'

	$wshshell = New-Object -ComObject WScript.Shell
	$lnk = $wshshell.CreateShortcut($inputTempFile)
	$lnk.TargetPath = $powershellPath
    $lnk.Arguments = " -NoExit -Command `"cd ~\\`""
	$lnk.IconLocation = Join-Path $libDir 'chocolatey.ico'
	$lnk.WorkingDirectory = ""
	$lnk.Save()

	# Taken from BoxStarter:Create-Shortcut
	# https://github.com/mwrock/boxstarter/blob/master/BuildScripts/setup.ps1
	# https://social.msdn.microsoft.com/Forums/en-US/b105603f-b81f-443d-8521-0105e69448d2/create-shortcut-with-run-as-administrator-program-option?forum=visualfoxprogeneral

	$outputTempFile = [System.IO.Path]::GetTempFileName()

	$writer = new-object System.IO.FileStream $outputTempFile, ([System.IO.FileMode]::Create)
	$reader = new-object System.IO.FileStream $inputTempFile, ([System.IO.FileMode]::Open)

	while ($reader.Position -lt $reader.Length)
	{
		$byte = $reader.ReadByte()
		if ($reader.Position -eq 22) {
			$byte = 34
		}
		$writer.WriteByte($byte)
	}

	$reader.Close()
	$writer.Close()

	Copy-Item -Path $outputTempFile (Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::DesktopDirectory)) 'Chocolatey Shell.lnk') -Force | Out-Null
	Copy-Item -Path $outputTempFile (Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Chocolatey Shell.lnk') -Force | Out-Null

	Write-Host "Chocolatey shell has been linked as a shortcut on your desktop and in your start menu."

	Write-ChocolateySuccess 'ChocolateyShell'
} catch {
	Write-ChocolateyFailure 'ChocolateyShell' $($_.Exception.Message)
	throw
}
