$packageName = '{{PackageName}}'

# Instructions for silent installation: http://support.balsamiq.com/customer/portal/articles/133390
$installPath = Join-Path ${env:ProgramFiles(x86)} "Balsamiq Mockups 3"

# Delete desktop shortcut
$currentUser = (Get-WMIObject -class Win32_ComputerSystem | select username).username
if ($currentUser -match "\\") {
    $currentUser = $currentUser.Substring($currentUser.IndexOf("\") + 1)
}
$usersDir = Split-Path $env:USERPROFILE -Parent
$currentUserDir = Join-Path $usersDir $currentUser
$currentUserDesktopDir = Join-Path $currentUserDir "Desktop"
$desktopLinkPath = Join-Path $currentUserDesktopDir "Balsamiq Mockups 3.exe.lnk"
if (Test-Path $desktopLinkPath) {
    Write-Host "Deleting Desktop shortcut..."
    $elevatedRemoveShortcut = "`
    Remove-Item '$desktopLinkPath' -Force;`
    return 0;"
    Start-ChocolateyProcessAsAdmin $elevatedRemoveShortcut
}

# Remove file type registration
Write-Host "Removing file type registration..."
$elevatedRemoveFileAssociation = "`
if( -not (Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};`
if(test-path -LiteralPath 'HKCR:\.bmml') { remove-item -Path 'HKCR:\.bmml' -Recurse };`
if(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile') { remove-item -Path 'HKCR:\com.balsamiq.mockupfile' -Recurse };`
return 0;"
Start-ChocolateyProcessAsAdmin $elevatedRemoveFileAssociation

# Delete application files
if (Test-Path $installPath) {
    Write-Host "Deleting application files..."
    $elevatedRemoveFiles = "`
    Remove-Item '$installPath' -Force -Recurse;`
    return 0;"
    Start-ChocolateyProcessAsAdmin $elevatedRemoveFiles
}
