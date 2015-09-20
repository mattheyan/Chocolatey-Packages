$toolsPath = (Split-Path -parent $MyInvocation.MyCommand.Definition)
. "$toolsPath\extensions.ps1"

$applicationPath = (Join-Path (Split-Path -parent $toolsPath) "application")
$file = (Get-ChildItem -Path $applicationPath -Filter *.zip | Select-Object -First 1).FullName
$packageName = '{{PackageName}}'

# Create variable for program files directory
# ===========================================
# Borrowed from BoxStarter.Azure
if(${env:ProgramFiles(x86)} -ne $null) {
    $programFiles86 = ${env:ProgramFiles(x86)}
} else {
    $programFiles86 = $env:ProgramFiles
}

$arguments = (ParseParameters $env:chocolateyPackageParameters)

# Instructions for silent installation: http://support.balsamiq.com/customer/portal/articles/133390
$installPath = Join-Path $programFiles86 "Balsamiq Mockups 3"

# Download and extract ZIP file
Get-ChocolateyUnzip -fileFullPath $file -destination "$programFiles86"
Write-Host "Moving application files..."
Rename-Item (Join-Path $programFiles86 'Balsamiq_Mockups_3') $installPath

$balsamiqExe = Join-Path $installPath "Balsamiq Mockups 3.exe"

if($arguments.ContainsKey("licenseCode") -and $arguments.ContainsKey("licenseName")) {

    $licenseCode = $arguments["licenseCode"]
    $licenseName = $arguments["licenseName"]

    Start-Process $balsamiqExe -ArgumentList "register ""$licenseName"" ""$licenseCode"""
}

# Add file type registration
<#
Write-Host "Adding file type registration..."
$elevatedSetFileAssociation = "`
if( -not (Test-Path -path HKCR:) ) {New-PSDrive -Name HKCR -PSProvider registry -Root Hkey_Classes_Root};`
if(!(test-path -LiteralPath 'HKCR:\.bmml')) { new-item -Path 'HKCR:\.bmml' };`
Set-ItemProperty -LiteralPath 'HKCR:\.bmml' -Name '(Default)'  -Value 'com.balsamiq.mockupfile';`
Set-ItemProperty -LiteralPath 'HKCR:\.bmml' -Name 'Content Type'  -Value 'application/xml';`
if(!(test-path -LiteralPath 'HKCR:\.bmml\OpenWithProgIds')) { new-item -Path 'HKCR:\.bmml\OpenWithProgIds' };`
Set-ItemProperty -LiteralPath 'HKCR:\.bmml\OpenWithProgIds' -Name 'com.balsamiq.mockupfile' -Value '';`
if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile' };`
Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile' -Name '(Default)' -Value 'Balsamiq Mockups Markup Language';`
if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\DefaultIcon')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\DefaultIcon' };`
Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile\DefaultIcon' -Name '(Default)' -Value '\""$balsamiqExe\"",-105';`
if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell' };`
if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell\open' };`
if(!(test-path -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open\command')) { new-item -Path 'HKCR:\com.balsamiq.mockupfile\shell\open\command' };`
Set-ItemProperty -LiteralPath 'HKCR:\com.balsamiq.mockupfile\shell\open\command' -Name '(Default)' -Value '\""$balsamiqExe\"" \""%1\""';`
return 0;"
Start-ChocolateyProcessAsAdmin $elevatedSetFileAssociation
#>

$shortcutPath = [environment]::GetFolderPath([environment+specialfolder]::Programs)
$shortcutFilePath = Join-Path $shortcutPath "Balsamiq Mockups 3.lnk"

# Create shortcut in Startmenu
Install-ChocolateyShortcut -shortcutFilePath $shortcutFilePath -targetPath $balsamiqExe
