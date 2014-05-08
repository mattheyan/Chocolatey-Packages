try {
	$packageName = 'visualstudio2013-modelingsdk'
	$downloadUrl = 'http://download.microsoft.com/download/D/3/4/D3421F7D-B283-4113-B98A-CA9396A7E906/VS_VmSdk.exe'

	$logFilePath = Join-Path $env:TEMP 'VS_VmSdk.log'
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
