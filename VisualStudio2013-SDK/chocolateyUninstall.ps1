try {
	$packageName = 'visualstudio2013-sdk'
	$exeFileName = 'vssdk_full.exe'
	$productVersion = '12.0'

	$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter $exeFileName | ? { $_.VersionInfo.ProductVersion.StartsWith($productVersion) }
	if (!$installer) {
		throw "Could not find installer package with file name $exeFileName and product version $productVersion."
	}

	$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
	Uninstall-ChocolateyPackage $packageName 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}