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

$uninstallString = $null

try {
    $currentInstall = Get-Software 'Microsoft OneDrive' -EA 0

    if ($currentInstall) {
        $uninstallString = $currentInstall.UninstallString
    }
} catch {
    if ($_.Exception.Message -eq "Didn't find software matching name 'Microsoft OneDrive'.") {
        # Ignore error...
    } else {
        Write-Warning "Unable to determine current version: '$($_.Exception.Message)'."
    }
}

if ($uninstallString) {
    Write-Host "Running uninstall string => $uninstallString"
    Start-ChocolateyProcessAsAdmin "/C $uninstallString" 'cmd.exe' -validExitCodes @(0)
} else {
    Write-Warning "OneDrive is not installed for user '$($env:USERNAME)'."
}
