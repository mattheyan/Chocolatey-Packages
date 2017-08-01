$root = Split-Path $MyInvocation.MyCommand.Path -Parent

include '..\psake-common.ps1'

. "$($root)\psake-helpers.ps1"

properties {
	$chocoSource = 'chocolatey.org'
	$chocoApiKey = $env:Chocolatey_ApiKey
	$chocoSourceHost = 'myget'
	$chocoPackageVersion = ConvertFrom-VersionString (([xml](Get-Content "$($root)\OneDrive.nuspec")).package.metadata.version)
	$chocoPackageCache = $null
}

task ValidatePackage {
	$foundChecksum = $false

	$packageChecksums = @{}

	$packageChecksums['17.3.6798.0207'] = 'C1BDF2E4150AD93CB047AE339A44AB9612BA211475D8CA24C63303F7745D241C'
	$packageChecksums['17.3.6799.0327'] = '146C48916959C1B169BFEDE141AF4ECE75B44729DB24764D5CCCF5B17D422E98'
	$packageChecksums['17.3.6917.0607'] = '1C05CB79F29505F5DD617E41240D0E5D81A6D2EA80B423AD7DFAE9FBA1A814DC'
	$packageChecksums['17.3.6931.0609'] = '0474C9CD803B9C3AAF925B7B7D2AE5C1965F08B00E51CFAFA4EBA090FEB25FE4'
	$packageChecksums['17.3.6941.0614'] = 'DA088AB575B08B504ACBECD2E1DEED98BD75AA30959616F23CA765C35B561DD7'
	$packageChecksums['17.3.6943.0625'] = 'CF32BDCFED60D29ADFF3139FE604B92F024CFEC2E9D994A14D1487F1F9B323CA'
	$packageChecksums['17.3.6944.0627'] = '5B111BBF771E46008B5593EFC24137FC142D3170BA6F49DD9F46011667A57EA9'

	$chocoPackageVersionChecksum = $packageChecksums[$chocoPackageVersion.VersionNumber]

	if (-not($chocoPackageVersionChecksum)) {
		throw "Didn't find checksum for version '$($chocoPackageVersion.VersionNumber)'."
	}

	if ($chocoPackageCache) {
		$cachedFile = "$($chocoPackageCache)\v$($chocoPackageVersion.VersionNumber)\OneDriveSetup.exe"
		if (Test-Path $cachedFile) {
			$checksum = C:\ProgramData\chocolatey\tools\checksum.exe -f="`"$($cachedFile)`"" -t=sha256
			if ($LASTEXITCODE -ne 0) {
				Write-Warning "Getting checksum failed with exit code $($LASTEXITCODE)."
			} else {
				Write-Host "Calculated checksum '$($checksum.Trim())' for version '$($chocoPackageVersion.VersionNumber)'."
				if ($chocoPackageVersionChecksum -ne $checksum.Trim()) {
					throw "Recorded checksum does not match cached file."
				}
			}
		} else {
			Write-Warning "Didn't find cached file to validate checksum."
		}
	}

	$versionExpr = "(\d+\.\d+(?:\.\d+(?:\.\d+)?)?)"

	$checksumExpr = "^\s*checksum\s*=\s*'([^']+)'\s*$"

	$lineNum = 0
	Get-Content "$($root)\tools\chocolateyInstall.ps1" | %{
		$lineNum += 1
		if ($_ -match $versionExpr) {
			if ($_ -match "(?<![\d\.])$($versionExpr)(?![\d\.])") {
				$version = $_ -replace "^.*(?<![\d\.])$($versionExpr)(?![\d\.]).*$", '$1'
				if ($version -ne $chocoPackageVersion.VersionNumber) {
					throw "Found unexpected version number on line $($lineNum): $($_)"
				}
			} else {
				throw "Found invalid version number on line $($lineNum): $($_)"
			}
		} elseif ($_ -match $checksumExpr) {
			$checksum = $_ -replace $checksumExpr, '$1'
			Write-Host "Found checksum '$($checksum)'."
			if ($checksum -eq $chocoPackageVersionChecksum) {
				$foundChecksum = $true
			} else {
				throw "Found invalid checksum on line $($lineNum): $($_)"
			}
		}
	}

	if (-not($foundChecksum)) {
		throw "Didn't find checksum for version '$($chocoPackageVersion.VersionNumber)'."
	}
}

task Build -depends EnsureMyGetConnected,ValidatePackage,Choco:BuildPackages

task Deploy -depends EnsureMyGetConnected,Choco:DeployPackages
