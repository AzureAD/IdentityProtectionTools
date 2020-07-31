## Set Strict Mode for Module. https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode
Set-StrictMode -Version 3.0

## Azure Automation module import fails when ScriptsToProcess is specified in manifest. Referencing import script directly.
#. (Join-Path $PSScriptRoot $MyInvocation.MyCommand.Name.Replace('.psm1', '.ps1'))

## Global Variables