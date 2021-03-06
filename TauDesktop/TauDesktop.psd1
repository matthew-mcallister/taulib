@{
RootModule = 'TauDesktop.psm1'
ModuleVersion = '0.0.6'
GUID = '98f2a88d-428b-4aae-939d-a3dc04ddf4c4'
Author = 'Matthew McAllister'
CompanyName = 'Trinity Alps Unified School District'
Copyright = '(c) 2021 Matthew McAllister. All rights reserved.'
Description = 'Desktop-related utilities for TAUSD'
FunctionsToExport = @(
    'Remove-StrayLocalusers',
    'Get-UserMachines',
    'Update-KerberosDelegationLists',
    'Test-PackageInstalled',
    'Install-TauApp'
)
CmdletsToExport = @()
VariablesToExport = @('$InstallerDir')
AliasesToExport = @()
PrivateData = @{
    PSData = @{
    }
}
}
