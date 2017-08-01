function ConvertFrom-VersionString {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true)]
        [string]$InputObject
    )

    if ($InputObject -like '*-*') {
        $versionFlagIndex = $InputObject.IndexOf('-')
        $versionNumber = $InputObject.Substring(0, $versionFlagIndex)
        $versionFlag = $InputObject.Substring($versionFlagIndex + 1)
    } else {
        $versionNumber = $InputObject
        $versionFlag = $null
    }

    $version = New-Object 'PSObject'

    $version | Add-Member -Type 'NoteProperty' -Name 'VersionString' -Value $InputObject
    $version | Add-Member -Type 'NoteProperty' -Name 'VersionNumber' -Value $versionNumber
    $version | Add-Member -Type 'NoteProperty' -Name 'VersionFlag' -Value $versionFlag

    return $version
}
