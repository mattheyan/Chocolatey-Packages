Write-Message "Loading file '$($MyInvocation.MyCommand.Path)'..."

if (-not($psake)) {
	throw "Script 'psake-common.ps1' must be run as a psake task."
}

if (-not($global:PsakeTaskRoot)) {
	$global:PsakeTaskRoot = $psake.build_script_dir
}

if (-not($root)) {
	# Legacy global variable...
	$global:root = $psake.build_script_dir
}

$global:PsakeProjectRoot = Split-Path $MyInvocation.MyCommand.Path -Parent

Write-Message "[[DarkGreen:PsakeTaskRoot]]: $PsakeTaskRoot"
Write-Message "[[DarkGreen:PsakeProjectRoot]]: $PsakeProjectRoot"

include "$($PSScriptRoot)\Modules\Psake-Choco\psake-tasks.ps1"

properties {
	if ($env:ChocolateyLocal -and (Test-Path $env:ChocolateyLocal)) {
		$outDir = $env:ChocolateyLocal
	} else {
		$outDir = Join-Path $env:LOCALAPPDATA (Split-Path $PsakeTaskRoot -Leaf)
		if (-not(Test-Path $outDir)) {
			New-Item $outDir -Type Directory | Out-Null
		}
	}

	$chocoOutDir = $outDir
	$chocoPkgsDir = $PsakeTaskRoot
}

if (Test-Path "$($PsakeProjectRoot)\psake-local.ps1") {
	Write-Message "Loading file '$($PsakeProjectRoot)\psake-local.ps1'..."
	include "$($PsakeProjectRoot)\psake-local.ps1"
}

if (Test-Path "$($PsakeTaskRoot)\psake-local.ps1") {
	Write-Message "Loading file '$($PsakeTaskRoot)\psake-local.ps1'..."
	include "$($PsakeTaskRoot)\psake-local.ps1"
}

task EnsureMyGetConnected {
    if (-not($chocoSourceHost)) {
	    $chocoSourceHost = 'myget'
    } elseif ($chocoSourceHost -ne 'myget') {
        throw "Unexpected chocolatey source host '$($chocoSourceHost)'."
    }

    if ($env:MyGet_ApiKey) {
	    $chocoApiKey = $env:MyGet_ApiKey
    } else {
        throw "Set enviornment variable 'MyGet_ApiKey' to provide access to the choco pkg destination."
    }
}
