# .SYNOPSIS
# Removes all local users *except* the administrator account.
function Remove-StrayLocalUsers {
    $strays = Get-LocalUser | Where-Object { $_.Enabled -and -not ($_.Name -eq 'Administrator') }
    Write-Output "Removing users: $($strays | Select-Object -ExpandProperty 'Name')"
    $cims = Get-CimInstance Win32_UserProfile
    $strays | ForEach-Object {
        $user = $_
        $cim = $cims | Where-Object { $_.SID -eq $user.SID }
        Remove-CimInstance $cim
        Remove-LocalUser $user
    }
}

# .SYNOPSIS
# Retrieves a list of PCs from Active Directory.
function Get-UserMachines {
    # TODO: Allow specifying a site and desktops or laptops
    Get-ADComputer -Filter "Name -like 'TH*' -or Name -like 'WE*' -or Name -like 'BB*'"
}

# .SYNOPSIS
# Updates the list of computer objects allowed to delegate Kerberos credentials
# to network services.
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
        Write-Output "Starting install of $name (may run in background)..."
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
        'Google Chrome' {
            Invoke-TauInstaller -Name $Name -InstallScript {
                & 'msiexec.exe' /L*v 'C:\install.log' /qn /I "$InstallerDir\GoogleChromeStandaloneEnterprise64.msi" 
            }
        }
        'vCastSender' {
            Invoke-TauInstaller -Name $Name -InstallScript {
                & 'msiexec.exe' /L*v 'C:\install.log' /qn /I "$InstallerDir\vCastSender\vCastSender_v3.0.2.1013.msi" 
            }
        }
        'Microsoft Office Professional Plus 2019 - en-us' {
            Invoke-TauInstaller -Name $Name -InstallScript {
                & "$InstallerDir\Office2019\setup.exe" '/configure' "$InstallerDir\Office2019\tausd-2019-pro.xml" 
            }
        }
        default {
            throw [System.ArgumentException]"App not available: $Name"
        }
    }
}