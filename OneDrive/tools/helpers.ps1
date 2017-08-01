function Get-Software {
	[CmdletBinding()]
	param(
		[string]$Name,

		[ValidateSet('Everything', 'CurrentUser', 'LocalMachine')]
		[string]$Scope = 'Everything'
	)

	# https://community.spiceworks.com/how_to/2238-how-add-remove-programs-works
	# http://superuser.com/questions/681564/how-to-list-all-applications-displayed-from-add-remove-winxp-win7-via-command-li
	# http://www.cagedrat.com/microsoft-windows/powershell/powershell-get-list-of-installed-programs-wmi-registry/

	if (-not($Scope)) {
		$Scope = 'CurrentUser'
	}

	$regKeys = @()

	if ($Scope -eq 'LocalMachine' -or $Scope -eq 'Everything') {
		Get-ChildItem "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -EA 0 | ForEach-Object {
			$regKeys += $_
		}
	}

	if ($Scope -eq 'CurrentUser' -or $Scope -eq 'Everything') {
		Get-ChildItem "HKCU:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall" -EA 0 | ForEach-Object {
			$regKeys += $_
		}
	}

	if ($Scope -eq 'LocalMachine' -or $Scope -eq 'Everything') {
		Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -EA 0 | ForEach-Object {
			$regKeys += $_
		}
	}

	if ($Scope -eq 'CurrentUser' -or $Scope -eq 'Everything') {
		Get-ChildItem "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall" -EA 0 | ForEach-Object {
			$regKeys += $_
		}
	}

	$software = [array]($regKeys | ForEach-Object {
		Get-ItemProperty $_.PSPath
	} | Where-Object {
		$_.SystemComponent -ne 1 -and $_.DisplayName -and -not($_.ParentDisplayName)
	} | Where-Object {
		-not($Name) -or $_.DisplayName -like $Name
	})

	if ($Name -and $software.Count -eq 0) {
		Write-Error "Didn't find software matching name '$($Name)'."
	}

	return $software
}

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

function Test-LoggedOnUser {
	[CmdletBinding()]
	param(
	)

    # https://support.microsoft.com/en-us/help/243330/well-known-security-identifiers-in-windows-operating-systems
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent().Name
    if ($currentUser -eq 'NT AUTHORITY\SYSTEM') {
        return $false
    } elseif ($currentUser -eq 'NT AUTHORITY\LOCAL SERVICE') {
        return $false
    } elseif ($currentUser -eq 'NT AUTHORITY\NETWORK SERVICE') {
        return $false
    } elseif ($env:USERNAME) {
		return $true
	}
}
