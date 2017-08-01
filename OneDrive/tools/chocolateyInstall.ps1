
[CmdletBinding()]
param(
  [string]$PackageName = $env:chocolateyPackageName,
  [string]$PackageFolder = $env:chocolateyPackageFolder,
  [string]$PackageVersion = $env:chocolateyPackageVersion,
  [switch]$Force = $($env:ChocolateyForce -eq 'True')
)

$ErrorActionPreference = 'Stop'

Write-Verbose "Importing file '.\tools\helpers.ps1'..."
. "$($PackageFolder)\tools\helpers.ps1"

# The install will fail if run as SYSTEM or a service account.
# https://support.office.com/en-us/article/Deploy-the-new-OneDrive-sync-client-in-an-enterprise-environment-3f3a511c-30c6-404a-98bf-76f95c519668?ui=en-US&rs=en-US&ad=US#step2
# "This command must be run at user logon and using Administrator permissions. It must be run for each user on a machine."
if (-not(Test-LoggedOnUser)) {
	Write-Warning "OneDrive setup must be run as a logged on user, the command will likely fail."
}

$PackageVersionObj = ConvertFrom-VersionString $PackageVersion

$PackageVersionNumber = $PackageVersionObj.VersionNumber

if ($PackageVersionObj.VersionFlag) {
  if ($PackageVersionObj.VersionFlag -eq 'Insider') {
    $PackageDownloadSource = 'Team'
  } else {
    throw "Unexpected version flag '$($PackageVersionObj.VersionFlag)'."
  }
} else {
  $PackageDownloadSource = 'Direct'
}

if (-not($Force.IsPresent)) {
	try {
		$currentInstall = Get-Software 'Microsoft OneDrive' -EA 0

		if ($currentInstall) {
			if ($currentInstall.DisplayVersion -gt $PackageVersionNumber) {
				Write-Warning "OneDrive v$($currentInstall.DisplayVersion) is already installed."
				return
			} elseif ($currentInstall.DisplayVersion -eq $PackageVersionNumber) {
				Write-Warning "OneDrive v$($currentInstall.DisplayVersion) is already installed."
				return
			}
		}
	} catch {
		if ($_.Exception.Message -eq "Didn't find software matching name 'Microsoft OneDrive'.") {
			# Ignore error...
		} else {
			Write-Warning "Unable to determine current version: '$($_.Exception.Message)'."
		}
	}
}

Write-Host "Installing OneDrive v$($PackageVersionNumber)..."

$packageArgs = @{
  packageName            = 'onedrive'
  fileType               = 'exe'
  url                    = "https://oneclient.sfx.ms/Win/$($PackageDownloadSource)/$($PackageVersionNumber)/OneDriveSetup.exe"
  checksum               = 'C1BDF2E4150AD93CB047AE339A44AB9612BA211475D8CA24C63303F7745D241C'
  checksumType           = 'sha256'
  silentArgs             = '/silent'
  validExitCodes         = @(0)
  softwareName           = 'Microsoft OneDrive'
}

Install-ChocolateyPackage @packageArgs
