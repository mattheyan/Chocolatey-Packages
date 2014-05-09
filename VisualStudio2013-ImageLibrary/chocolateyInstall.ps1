try {
	$packageName = 'visualstudio2013-imagelibrary'
	$zipDownloadUrl = 'http://download.microsoft.com/download/0/6/0/0607D8EA-9BB7-440B-A36A-A24EB8C9C67E/VS2013%20Image%20Library.zip'
	$eulaDownloadUrl = 'http://download.microsoft.com/download/0/6/0/0607D8EA-9BB7-440B-A36A-A24EB8C9C67E/Visual%20Studio%202013%20Image%20Library%20EULA.docx'

	# NOTE: Borrowed from BoxStarter.Azure
	if (${env:ProgramFiles(x86)} -ne $null) {
		$programFiles86 = ${env:ProgramFiles(x86)}
	} else {
		$programFiles86 = $env:ProgramFiles
	}

	$targetPath = Join-Path $programFiles86 "Microsoft Visual Studio 12.0 Image Library"

	Install-ChocolateyZipPackage $packageName $zipDownloadUrl $targetPath

	$currentDir = Split-Path $MyInvocation.MyCommand.Definition -Parent
	Get-ChocolateyWebFile $packageName (Join-Path $currentDir 'Visual%20Studio%202013%20Image%20Library%20EULA.docx') $eulaDownloadUrl

    Write-ChocolateySuccess $packageName
} catch {
	Write-ChocolateyFailure $packageName $($_.Exception.Message)
	if ($logFilePath) {
		Write-Host "HINT: check log file '$($logFilePath)'."
	}
	throw
}
