[CmdletBinding()]
param(
    # The path to the installer file to test
    [Parameter(Mandatory=$true)]
    [string]$Path,

    # The company name expression that the installer should match
    [string]$CompanyName,

    # The product name expression that the installer should match
    [string]$ProductName,

    # The product version expression that the installer should match
    [string]$ProductVersion
)

if (-not(Test-Path $Path)) {
    Write-Error "File '$($Path)' doesn't exist."
    return
}

$file = Get-Item $Path

$info = $file.VersionInfo

if ($CompanyName) {
    if ($info.CompanyName -like $CompanyName) {
        Write-Verbose "Company '$($info.CompanyName)' matches '$($CompanyName)'."
    } else {
        Write-Verbose "Company '$($info.CompanyName)' doesn't match '$($CompanyName)'."
        return $false
    }
}

if ($ProductName) {
    if ($info.ProductName -like $ProductName) {
        Write-Verbose "Product '$($info.ProductName)' matches '$($ProductName)'."
    } else {
        Write-Verbose "Product '$($info.ProductName)' doesn't match '$($ProductName)'."
        return $false
    }
}

if ($ProductVersion) {
    if ($info.ProductVersion -like $ProductVersion) {
        Write-Verbose "Version '$($info.ProductVersion)' matches '$($ProductVersion)'."
    } else {
        Write-Verbose "Version '$($info.ProductVersion)' doesn't match '$($ProductVersion)'."
        return $false
    }
}

return $true
