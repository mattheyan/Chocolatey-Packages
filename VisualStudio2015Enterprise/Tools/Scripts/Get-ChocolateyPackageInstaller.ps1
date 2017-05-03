[CmdletBinding()]
param(
    [string]$PackageName,

    # The path to the installer file to test
    [Parameter(Mandatory=$true)]
    [string]$FileName,

    # The company name expression that the installer should match
    [string]$CompanyName,

    # The product name expression that the installer should match
    [string]$ProductName,

    # The product version expression that the installer should match
    [string]$ProductVersion
)

if (-not($PackageName)) {
    $PackageName = $env:chocolateyPackageName
    if (-not($PackageName)) {
        Write-Error "Parameter 'PackageName' is required."
        return
    }
}

if ($env:chocolateyShortcuts) {
    if (Test-Path $env:chocolateyShortcuts) {
        if (Test-Path "$($env:chocolateyShortcuts)\$($PackageName).lnk") {
            $ws = New-Object -COM 'WScript.Shell'
            $shortcut = $ws.CreateShortcut("$($env:chocolateyShortcuts)\$($PackageName).lnk")
            $targetPath = $shortcut.TargetPath

            if ($targetPath) {
                Write-Host "Found shortcut to path '$($targetPath)'."

                if (Test-Path $targetPath) {
                    $targetItem = Get-Item $targetPath
                    if ($targetItem.PSIsContainer) {
                        if (Test-Path "$($targetPath)\$($FileName)") {
                            if (& "$($PSScriptRoot)\Test-Installer.ps1" -Path "$($targetPath)\$($FileName)" -CompanyName $CompanyName -ProductName $ProductName -ProductVersion $ProductVersion -EA 0) {
                                $sourceDir = $targetPath
                                $installerPath = "$($targetPath)\$($FileName)"
                                Write-Host "Found installer at '$($installerPath)'."
                                return $installerPath
                            } else {
                                Write-Warning "File '$($targetPath)\$($FileName)' does not match the criteria."
                            }
                        }
                    } elseif ([System.IO.Path]::GetExtension($targetPath) -eq '.iso') {
                        Write-Host "Mounting file '$($targetPath)'..."
                        $mountedDrive = & "$($PSScriptRoot)\Mount-InstallerImage.ps1" -Path $targetPath
                        $mountedISO = $targetPath
                    }
                } else {
                    Write-Warning "Shortcut '$($env:chocolateyShortcuts)\$($PackageName).lnk' target '$($targetPath)' does not exist."
                }
            } else {
                Write-Warning "Shortcut '$($env:chocolateyShortcuts)\$($PackageName).lnk' has no target."
            }
        } else {
            Write-Host "Didn't find '$($PackageName).lnk' in Chocolatey shortcuts directory '$($env:chocolateyShortcuts)'."
        }
    } else {
        Write-Host "Chocolatey shortcuts directory '$($env:chocolateyShortcuts)' doesn't exist."
    }
} else {
    Write-Host "Chocolatey shortcuts directory is not defined."
}

Write-Host "Searching for mounted drive with install media for '$($PackageName)'..."
$installer = & "$($PSScriptRoot)\Find-MountedInstaller.ps1" -RelativePath $FileName -CompanyName $CompanyName -ProductName $ProductName -ProductVersion $ProductVersion -EA 0
if ($installer) {
    Write-Host "Found installer at '$($installer.FullName)'."
    return $installer.FullName
}

Write-Error "Unable to find installer for package '$($PackageName)'."
