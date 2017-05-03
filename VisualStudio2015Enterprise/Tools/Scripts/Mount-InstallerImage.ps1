[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$Path
)

if (-not(Test-Path $Path)) {
    Write-Error "File '$(Path)' doesn't exist."
    return
}

if ([System.IO.Path]::GetExtension($Path) -ne '.iso') {
    Write-Error "File '$(Path)' is not a mountable ISO."
    return
}

# http://boxstarter.codeplex.com/discussions/481444
$beforeDrives = (Get-Volume).DriveLetter
Write-Verbose "Drive (before): $(($beforeDrives | Where-Object { $_ }) -join ", ")"
Write-Verbose "Mounting disk image..."
Mount-DiskImage -ImagePath $Path
$afterDrives = (Get-Volume).DriveLetter
Write-Verbose "Drives (after): $(($afterDrives | Where-Object { $_ }) -join ", ")"
Compare-Object ($beforeDrives | Where-Object { $_ }) ($afterDrives | Where-Object { $_ }) -Passthru | ForEach-Object {
    Write-Verbose "Enabling drive '$($_)'..."
    New-PSDrive -Name $_ -PSProvider FileSystem -Root "$($_):\" -ErrorAction SilentlyContinue | Out-Null
}
$mounted = $true
$driveLetter = (Get-DiskImage $Path | Get-Volume).DriveLetter

return "$($driveLetter):\"
