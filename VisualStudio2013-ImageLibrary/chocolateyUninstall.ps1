try {
	$packageName = 'visualstudio2013-imagelibrary'
	$zipFileName = 'VS2013%20Image%20Library.zip'

	UnInstall-ChocolateyZipPackage $packageName $zipFileName

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}
