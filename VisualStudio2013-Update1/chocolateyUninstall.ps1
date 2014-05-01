try {
	$packageName = 'visualstudio2013-update1'

	# NOTE: Borrowed from BoxStarter.Azure
	if (${env:ProgramFiles(x86)} -ne $null) {
		$programFiles86 = ${env:ProgramFiles(x86)}
	} else {
		$programFiles86 = $env:ProgramFiles
	}

	Write-Host "Checking for Visual Studio 2013..."
	if (Test-Path (Join-Path $programFiles86 'Microsoft Visual Studio 12.0\Common7\IDE\devenv.exe')) {
		Write-Host "Visual Studio 2013 is installed, checking updates..."

		$baseVersion = '12.0.21005'
		$update1Version = '12.0.30110'
		$update2Version = '12.0.30324'
		$currentVersion = (get-itemproperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\DevDiv\vs\Servicing\12.0\premium\1033' 'UpdateVersion').UpdateVersion
		if ($currentVersion -eq $baseVersion) {
			Write-Host "Visual Studio 2013 Update 1 is not installed."
		}
		elseif ($currentVersion -eq $update1Version) {
			Write-Host "Removing Visual Studio 2013 update 1..."
			$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter 'VS2013.1.exe'
			$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
			Uninstall-ChocolateyPackage '"VS2013.1.exe"' 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)
		}
		elseif ($currentVersion -eq $update2Version) {
			throw "Visual Studio 2013 Update 2 is installed!"
		}
		else {
			throw "Unexpected Visual Studio 2013 Update version '$($currentVersion)'!"
		}
	}
	else {
		Write-Host "Visual Studio 2013 is not installed."
	}

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}
