$toolsDir = Split-Path $MyInvocation.MyCommand.Definition -Parent

Import-Module (Join-Path $toolsDir 'VSModules.psm1')

$fileName = 'vs_enterprise.exe'
$companyName = 'Microsoft Corporation'
$productName = 'Microsoft Visual Studio Enterprise 2015'
$productVersion = '14.0.*' 

$installerPath = & "$($toolsDir)\Scripts\Get-ChocolateyPackageInstaller.ps1" -FileName $fileName -CompanyName $CompanyName -ProductName $ProductName -ProductVersion $ProductVersion -EA 0 -Verbose

if ($installerPath) {
    $env:visualStudio:setupFolder = "$(Split-Path $installerPath -Parent)"
}

Install-VS 'VisualStudio2015Enterprise' 'https://download.microsoft.com/download/6/4/7/647EC5B1-68BE-445E-B137-916A0AE51304/vs_enterprise.exe' 'vs_enterprise.exe' '2848DDD11A5DB48F801A846A4C7162027CA2ADE2EF252143ABDE82AD9C9FDD97'
