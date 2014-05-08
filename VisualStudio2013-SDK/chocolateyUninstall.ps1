try {
	$packageName = 'visualstudio2013-sdk'

	$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter 'vssdk_full.exe'
	$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
	Uninstall-ChocolateyPackage $packageName 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}
