try {
	$packageName = 'visualstudio2013-installerprojects'
	$downloadUrl = 'http://visualstudiogallery.msdn.microsoft.com/9abe329c-9bba-44a1-be59-0fbf6151054d/file/130817/1/VSI_bundle.exe'

	$logFilePath = Join-Path $env:TEMP 'VSI_bundle.log'
	$installArgs = '/Passive /NoRestart /Log ' + $logFilePath
	Install-ChocolateyPackage 'VSI_bundle.exe' 'exe' $installArgs $downloadUrl -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	if ($logFilePath) {
		Write-Host "HINT: check log file '$($logFilePath)'."
	}
	throw
}
