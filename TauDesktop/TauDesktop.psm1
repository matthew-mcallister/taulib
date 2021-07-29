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