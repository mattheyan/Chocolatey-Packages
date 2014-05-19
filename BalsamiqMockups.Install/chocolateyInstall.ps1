try {
	# Instructions for silent installation: http://support.balsamiq.com/customer/portal/articles/133390
	$installPath = Join-Path ${env:ProgramFiles(x86)} "Balsamiq Mockups"

	# Download and extract ZIP file
	$tempDir = [System.IO.Path]::GetTempFileName().Replace(".", "")
	$zipUrl = "http://builds.balsamiq.com/b/mockups-desktop/MockupsForDesktop.zip"
	Install-ChocolateyZipPackage "balsamiqmockups" $zipUrl $tempDir

	# Move child folder into target folder
	Move-Item (Join-Path $tempDir "MockupsForDesktop") $installPath
	
	# TODO: Add file type registration

	Write-ChocolateySuccess "balsamiqmockups.install"
} catch {
    Write-ChocolateyFailure "balsamiqmockups.install" $($_.Exception.Message)
    throw
}
