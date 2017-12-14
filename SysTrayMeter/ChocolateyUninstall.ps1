$packageName = "systraymeter"

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

# Delete startup shortcut
$currentUser = (Get-WMIObject -class Win32_ComputerSystem | select username).username
if ($currentUser -match "\\") {
	$currentUser = $currentUser.Substring($currentUser.IndexOf("\") + 1)
}
$usersDir = Split-Path $env:USERPROFILE -Parent
$currentUserDir = Join-Path $usersDir $currentUser
$currentUserStartupDir = Join-Path $currentUserDir "AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
$startupLinkPath = Join-Path $currentUserStartupDir "SysTrayMeter.lnk"
if (Test-Path $startupLinkPath) {
	Write-Host "Deleting startup shortcut link..."
	Remove-Item $startupLinkPath
}

# Remove application binaries
Write-Host "Removing application files..."
$targetDir = "$programFiles86\SysTrayMeter"
Remove-Item $targetDir -Recurse -Force | Out-Null
