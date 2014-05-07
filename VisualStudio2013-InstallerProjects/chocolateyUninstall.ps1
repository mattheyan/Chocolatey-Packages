try {
	$packageName = 'visualstudio2013-installerprojects'

	$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter 'VSI_bundle.exe'
	$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
	Uninstall-ChocolateyPackage 'VSI_bundle.exe' 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}
