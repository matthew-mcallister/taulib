# .SYNOPSIS
# Removes all local users *except* the administrator account.
function Remove-StrayLocalUsers {
    $strays = Get-LocalUser | Where-Object { $_.Enabled -and -not ($_.Name -eq 'Administrator') }
    Write-Output "Removing users: $($strays | Select-Object -ExpandProperty 'Name')"
    $strays | Remove-LocalUser
}

# .SYNOPSIS
# Retrieves a list of PCs from Active Directory.
function Get-UserMachines {
    # TODO: Allow specifying a site and desktops or laptops
    Get-ADComputer -Filter "Name -like 'TH*' -or Name -like 'WE*' -or Name -like 'BB*'"
}

# .SYNOPSIS
# Updates the list of computer objects allowed to delegate Kerberos credentials
# to our servers.
function Update-KerberosDelegationLists {
    Set-ADComputer 'data-tausd' -PrincipalsAllowedToDelegateToAccount (Get-UserMachines)
}

$InstallerDir = '\\data-tausd\Shares\Technology\Installers'

function Test-PackageInstalled {
    param (
        [Parameter(Mandatory)]
        [string]
        $Package
    )
    try {
        $ErrorActionPreference = 'Stop'
        [bool](Get-Package $Package)
    }
    catch {
        $false
    }
}

function Install-GoogleDrive {
    if (-not (Test-PackageInstalled 'Google Drive')) {
        Write-Output 'Starting background install of Google Drive...'
        & "$InstallerDir\GoogleDriveSetup.exe" --silent --gsuite_shortcuts=false
    }
}

function Invoke-TauInstaller {
    param (
        [Parameter(Mandatory)]
        [string]
        $Name,
        [Parameter(Mandatory)]
        [scriptblock]
        $InstallScript
    )
    if (-not (Test-PackageInstalled $Name)) {
        Write-Output "Starting background install of $name..."
        & $InstallScript
    }
}

# .SYNOPSIS
# Invokes the installer for one of a predefined list of applications.
function Install-TauApp {
    param (
        [Parameter(Mandatory)]
        [string]
        $Name
    )
    # TODO: Replace with an enum
    switch -CaseSensitive ($Name) {
        'Google Drive' {
            Invoke-TauInstaller -Name $Name -InstallScript {
                & "$InstallerDir\GoogleDriveSetup.exe" --silent --gsuite_shortcuts=false
            }
        }
        default {
            throw [System.ArgumentException]"App not available: $Name"
        }
    }
}