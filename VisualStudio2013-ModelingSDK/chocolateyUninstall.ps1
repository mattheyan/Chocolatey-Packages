try {
	$packageName = 'visualstudio2013-modelingsdk'

	$installer = ls (Join-Path $env:ProgramData "Package Cache") -Recurse -Filter 'VS_VmSdk.exe'
	$uninstallArgs = '/Uninstall /Force /Passive /NoRestart'
	Uninstall-ChocolateyPackage $packageName 'exe' $uninstallArgs $installer.FullName -validExitCodes @(0,3010)

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	throw
}
