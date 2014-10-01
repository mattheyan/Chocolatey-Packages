try {
	# Create variable for program files directory
	# ===========================================
	# Borrowed from BoxStarter.Azure
	if(${env:ProgramFiles(x86)} -ne $null) {
		$programFiles86 = ${env:ProgramFiles(x86)}
	} else {
		$programFiles86 = $env:ProgramFiles
	}

	# Instructions for silent installation: http://support.balsamiq.com/customer/portal/articles/133390
	$installPath = Join-Path $programFiles86 "Balsamiq Mockups"

	# Download and extract ZIP file
	$tempDir = [System.IO.Path]::GetTempFileName().Replace(".", "")
	$zipUrl = "http://builds.balsamiq.com/b/mockups-desktop/MockupsForDesktop.zip"
	Write-Host "Downloading zip file..."
	Install-ChocolateyZipPackage "balsamiqmockups" $zipUrl $tempDir

	# Move child folder into target folder
	Write-Host "Moving application files..."
	$sourcePath = Join-Path $tempDir 'MockupsForDesktop'	
	$elevatedMoveFiles = "`
	Move-Item '$sourcePath' '$installPath';`
	return 0;"
	Start-ChocolateyProcessAsAdmin $elevatedMoveFiles

	# Add file type registration
	Write-Host "Adding file type registration..."
	$balsamiqExe = Join-Path $installPath "Balsamiq Mockups.exe"
	$elevatedSetFileAssociation = "`
    if( -not (Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};`
    if(!(test-path -LiteralPath 'HKCR:\.bmml')) { new-item -Path 'HKCR:\.bmml' };`
    Set-ItemProperty -LiteralPath 'HKCR:\.bmml' -Name '(Default)'  -Value 'com.balsamiq.mockupfile';`
    Set-ItemProperty -LiteralPath 'HKCR:\.bmml' -Name 'Content Type'  -Value 'application/xml';`
    if(!(test-path -LiteralPath 'HKCR:\.bmml\OpenWithProgIds')) { new-item -Path 'HKCR:\.bmml\OpenWithProgIds' };`
    Set-ItemProperty -LiteralPath 'HKCR:\.bmml\OpenWithProgIds' -Name 'com.balsamiq.mockupfile' -Value '';`
    if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile' };`
    Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile' -Name '(Default)' -Value 'Balsamiq Mockups Markup Language';`
    if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\DefaultIcon')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\DefaultIcon' };`
    Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile\DefaultIcon' -Name '(Default)' -Value '\""$balsamiqExe\"",-105';`
    if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell' };`
    if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell\open' };`
    if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open\command')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell\open\command' };`
    Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open\command' -Name '(Default)' -Value '\""$balsamiqExe\"" \""%1\""';`
    return 0;"
	Start-ChocolateyProcessAsAdmin $elevatedSetFileAssociation

	# Create desktop shortcut
	$wshShell = New-Object -COMObject WScript.Shell
	$currentUserDesktopDir = Join-Path $env:HOME "Desktop"
	$desktopLinkPath = Join-Path $currentUserDesktopDir "Balsamiq Mockups.lnk"
	if (!(Test-Path $desktopLinkPath)) {
		Write-Host "Creating Desktop shortcut..."
		$desktopShortcut = $wshShell.CreateShortcut($desktopLinkPath)
		$desktopShortcut.TargetPath = $balsamiqExe
		$desktopShortcut.Save()
	}

	Write-ChocolateySuccess "balsamiqmockups.install"
} catch {
    Write-ChocolateyFailure "balsamiqmockups.install" $($_.Exception.Message)
    throw
}
