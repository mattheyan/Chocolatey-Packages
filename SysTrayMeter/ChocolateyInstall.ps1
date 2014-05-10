try {
	$packageName = 'systraymeter'
	#$zipDownloadUrl = 'http://freewaregenius.com/wp-content/downloads/SysTrayMeter.zip'
	$zipDownloadUrl = 'http://software-files-a.cnet.com/s/software/10/76/89/96/SysTrayMeter.zip?lop=link&ptype=3001&ontid=2206&siteId=4&edId=3&spi=3a09c42872a00fbc85ba5963a881ac20&pid=10768996&psid=10768997&token=1399768782_49d9b9d48e3996c3320fe03c98b1852e&fileName=SysTrayMeter.zip'

	# Create variable for program files directory
	# ===========================================
	# Borrowed from BoxStarter.Azure
	if(${env:ProgramFiles(x86)} -ne $null) {
		$programFiles86 = ${env:ProgramFiles(x86)}
	} else {
		$programFiles86 = $env:ProgramFiles
	}

	# Close running application
	if (Get-Process -Name SysTrayMeter -ErrorAction SilentlyContinue) {
		Write-Host "Stopping process..."
		taskkill.exe /IM SysTrayMeter.exe /F
	}

	# Ensure target directory
	$targetDir = Join-Path $programFiles86 'SysTrayMeter'
	if (Test-Path $targetDir) {
		Write-Host "Updating application files..."
	}
	else {
		Write-Host "Creating application files..."
	}

	# Download and extract
	Install-ChocolateyZipPackage $packageName $zipDownloadUrl $targetDir

	$exePath = Join-Path $targetDir 'SysTrayMeter.exe'

	# Create startup shortcut
	# http://stackoverflow.com/questions/9701840/how-to-create-a-shortcut-using-powershell-or-cmd
	$currentUser = (Get-WMIObject -class Win32_ComputerSystem | select username).username
	if ($currentUser -match "\\") {
		$currentUser = $currentUser.Substring($currentUser.IndexOf("\") + 1)
	}
	$usersDir = Split-Path $env:USERPROFILE -Parent
	$currentUserDir = Join-Path $usersDir $currentUser
	$currentUserStartupDir = Join-Path $currentUserDir 'AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
	$startupLinkPath = Join-Path $currentUserStartupDir 'SysTrayMeter.lnk'
	$wshShell = New-Object -COMObject WScript.Shell
	$shortcut = $wshShell.CreateShortcut($startupLinkPath)
	$shortcut.TargetPath = $exePath
	$shortcut.Save()

	# Start application before exiting
	Write-Host "Starting application..."
	& $exePath

    Write-ChocolateySuccess $packageName
} catch {
  Write-ChocolateyFailure $packageName $($_.Exception.Message)
  throw
}
