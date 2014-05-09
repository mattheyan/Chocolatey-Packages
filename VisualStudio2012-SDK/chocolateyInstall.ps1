try {
	$packageName = 'visualstudio2012-sdk'
	$downloadUrl = 'http://download.microsoft.com/download/8/3/8/8387A8E1-E422-4DD5-B586-F1F2EC778817/vssdk_full.exe'

	$logFilePath = Join-Path $env:TEMP 'vssdk_full.log'
	$installArgs = '/Passive /NoRestart /Log ' + $logFilePath
	Install-ChocolateyPackage $packageName 'exe' $installArgs $downloadUrl -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	if ($logFilePath) {
		Write-Host "HINT: check log file '$($logFilePath)'."
	}
	throw
}
