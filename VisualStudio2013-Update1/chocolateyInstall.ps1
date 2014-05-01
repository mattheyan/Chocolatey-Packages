try {
	$packageName = 'visualstudio2013-update1'
	$downloadUrl = 'http://download.microsoft.com/download/8/2/6/826E264A-729E-414A-9E67-729923083310/VSU1/VS2013.1.exe'

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
		$update2Version = '12.0.30324'
		$currentVersion = (get-itemproperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\DevDiv\vs\Servicing\12.0\premium\1033' 'UpdateVersion').UpdateVersion
		if ($currentVersion -eq $baseVersion) {
			Write-Host "Installing Visual Studio 2013 update 1..."
			$logFilePath = Join-Path $env:TEMP 'VS20131.log'
			$installArgs = '/Passive /NoRestart /Log ' + $logFilePath
			Install-ChocolateyPackage 'VS2013.1.exe' 'exe' $installArgs $downloadUrl -validExitCodes @(0,3010)
		}
		elseif ($currentVersion -eq $update1Version) {
			Write-Host "Visual Studio 2013 Update 1 is already installed."
		}
		elseif ($currentVersion -eq $update2Version) {
			Write-Host "Visual Studio 2013 Update 2 is already installed."
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
