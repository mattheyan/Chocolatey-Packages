[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$RelativePath,
    [string]$CompanyName,
    [string]$ProductName,
    [string]$ProductVersion
)

Write-Verbose "Searching drives for installer media..."

$candidateDrives = Get-PSDrive -PSProvider FileSystem | Where-Object {
    # Filter out the system drive
    if ($_.Root -eq "$($env:SystemDrive)\") {
        Write-Verbose "Filtered out system drive '$($_.Name)'."
        return $false
    } else {
        return $true
    }
} | Where-Object {
    # Filter out network mapped drives
    if ($_.DisplayRoot -and $_.DisplayRoot.StartsWith('\\')) {
        Write-Verbose "Filtered out network mapped drive '$($_.Name)'."
        return $false
    } else {
        return $true
    }
}

if ($driveDescription) {
    # Look for a particular description of the drive
    $candidateDrives = $candidateDrives | Where-Object {
        if ($_.Description -ne $driveDescription) {
            Write-Verbose "Filtered out drive '$($_.Name)' since description '$($_.Description)'!='$($driveDescription)'."
            return $false
        } else {
            return $true
        }
    }
}

$candidateFiles = [array]($candidateDrives | ForEach-Object {
    $filePath = Join-Path $_.Root $RelativePath
    if (Test-Path $filePath) {
        Write-Verbose "Found candidate file '$($filePath)'."
        if (& "$($PSScriptRoot)\Test-Installer.ps1" -Path $filePath -CompanyName $CompanyName -ProductName $ProductName -ProductVersion $ProductVersion) {
            return $filePath
        }

    }
})

if ($candidateFiles.Count -gt 1) {
    Write-Warning "Returning the first of multiple matched files."
    Write-Output ($candidateFiles | Select-Object -First 1 | Get-Item)
} elseif ($candidateFiles.Count -eq 1) {
    Write-Output (Get-Item $candidateFiles[0])
} else {
    Write-Error "Couldn't find file '$($RelativePath)'."
}
