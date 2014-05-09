try {
	$packageName = 'visualstudio2012-modelingsdk'
	$downloadUrl = 'http://download.microsoft.com/download/6/5/C/65C5ECEF-FD1E-407E-9613-558EF0EEBAA2/VS_VmSdk.exe'
	$exeFileName = 'VS_VmSdk.exe'

	$logFilePath = Join-Path $env:TEMP ($exeFileName + '.log')
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
