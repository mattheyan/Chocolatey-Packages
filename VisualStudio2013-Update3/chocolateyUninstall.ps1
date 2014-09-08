try {
	$packageName = 'visualstudio2013-update3'

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
		$update2VersionA = '12.0.30324'
		$update2VersionB = '12.0.30501'
		$update3Version = '12.0.30723'
		$currentVersion = (get-itemproperty 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\DevDiv\vs\Servicing\12.0\devenv\1033' 'UpdateVersion').UpdateVersion
		if ($currentVersion -eq $baseVersion -or $currentVersion -eq $update1Version -or $currentVersion -eq $update2VersionA -or $currentVersion -eq $update2VersionB) {
			Write-Host "Visual Studio 2013 Update 3 is not installed."
		}
		elseif ($currentVersion -eq $update3Version) {
			Write-Host "Removing Visual Studio 2013 update 3..."
			$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter 'VS2013.3.exe'
			$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
			Uninstall-ChocolateyPackage '"VS2013.3.exe"' 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)
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
