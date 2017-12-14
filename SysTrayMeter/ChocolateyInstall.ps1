$packageName = 'systraymeter'
$zipDownloadUrl = 'http://freewaregenius.com/wp-content/downloads/SysTrayMeter.zip'

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
Install-ChocolateyShortcut `
	-ShortcutFilePath $startupLinkPath `
	-TargetPath $exePath `
	-WorkingDirectory $env:USERPROFILE

# Start application before exiting
Write-Host "Starting application..."
& $exePath
