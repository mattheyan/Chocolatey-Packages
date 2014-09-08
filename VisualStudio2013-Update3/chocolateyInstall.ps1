try {
	$packageName = 'visualstudio2013-update3'
	$downloadUrl = 'http://download.microsoft.com/download/0/4/1/0414085C-27A6-4842-ABC5-F545950A592F/VS2013.3.exe'

	# NOTE: Borrowed from BoxStarter.Azure
	if (${env:ProgramFiles(x86)} -ne $null) {
		$programFiles86 = ${env:ProgramFiles(x86)}
	} else {
		$programFiles86 = $env:ProgramFiles
	}

	Write-Host "Ensuring that Visual Studio 2013 is installed..."
	if (Test-Path (Join-Path $programFiles86 'Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe')) {
		Write-Host "Visual Studio 2013 is installed, checking updates..."

		$baseVersion = '12.0.21005'
		$update1Version = '12.0.30110'
		$update2VersionA = '12.0.30324'
		$update2VersionB = '12.0.30501'
		$update3Version = '12.0.30723'
		$currentVersion = (get-itemproperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\DevDiv\vs\Servicing\12.0\devenv\1033' 'UpdateVersion').UpdateVersion
		if ($currentVersion -eq $baseVersion -or $currentVersion -eq $update1Version -or $currentVersion -eq $update2VersionA -or $currentVersion -eq $update2VersionB) {
			Write-Host "Installing Visual Studio 2013 update 3..."
			$logFilePath = Join-Path $env:TEMP 'VS2013.3.log'
			$installArgs = '/Passive /NoRestart /Log ' + $logFilePath
			Install-ChocolateyPackage 'VS2013.3.exe' 'exe' $installArgs $downloadUrl -validExitCodes @(0,3010)
		}
		elseif ($currentVersion -eq $update3Version) {
			Write-Host "Visual Studio 2013 Update 3 is already installed."
		}
		else {
			throw "Unexpected Visual Studio 2013 Update version '$($currentVersion)'!"
		}
	}
	else {
		throw "Visual Studio 2013 is not installed!"
	}

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	if ($logFilePath) {
		Write-Host "HINT: check log file '$($logFilePath)'."
	}
	throw
}
