$installTargetPath = Join-Path $env:APPDATA 'SysInternals\Desktops'
New-Item -Path $installTargetPath -Type Directory -Force | Out-Null

Install-ChocolateyZipPackage 'Desktops' 'http://download.sysinternals.com/files/Desktops.zip' $installTargetPath

$exePath = Join-Path $installTargetPath 'Desktops.exe'

Install-ChocolateyDesktopLink $exePath

try {
    $desktopPath = Join-Path $env:USERPROFILE 'Desktop'
    $startMenuLocation = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu'
    Move-Item (Join-Path $desktopPath 'Desktops.exe.lnk') (Join-Path $startMenuLocation 'Desktops.lnk')
}
catch{
    Write-Output "WARNING - Unable to move desktop shortcut: $_.Exception.Message"
}

Start-Process $exePath
