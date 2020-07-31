<#
.SYNOPSIS
    Dismiss the risk of riskyUsers with elevated risk from Azure AD Identity Protection
.DESCRIPTION
    Dismiss the risk of riskyUsers with elevated risk from Azure AD Identity Protection
.EXAMPLE
    Invoke-AzureADIPDismissRiskyUser -UserIds @UserIdstoDismissRisk
    Dismiss the risk for the ObjectIDs
.EXAMPLE
    Invoke-AzureADIPDismissRiskyUser -UserIds @UserIdstoDismissRisk -Confirm:$false
    Dismiss the risk for the ObjectIDs
.EXAMPLE
    Another example of how to use this cmdlet
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    Parameters should be passed in as a collection of User ObjectIDs
    By default the Confirm Impact is High
#>
function Invoke-AzureADIPDismissRiskyUser {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        HelpUri = 'https://github.com/AzureAD/IdentityProtectionTools/',
        ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([String])]
    Param (
        # ObjectIDs of the users to dismiss as risky
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $UserIds
    )
    begin {

        $apiPermissionScopes = @("IdentityRiskyUser.Read.All", "IdentityRiskyUser.ReadWrite.All")
        if ($null -eq (Get-MgContext)) {
            Write-Error "Please Connect to MS Graph API with the Connect-Graph cmdlet from the Microsoft.Graph.Authentication module first before calling functions!" -ErrorAction Stop
        }
        else {
            if ($false -eq ((Get-MgContext).Scopes.Contains("IdentityRiskyUser.ReadWrite.All"))) {
                Write-Error "Current MS Graph Context does not contain the IdentityRiskyUser.ReadWrite.All scope required to call the IdentityProtection riskyUsers API.  Please ensure you are connecting with an identity that has this permission scope!" -ErrorAction Stop
            }
        }
    }
    process {
        $userCount = $UserIds.count
        Write-Verbose ("{0} User ObjectIDs will have their risk dismissed!" -f $userCount)
        Write-Information ("{0} User ObjectIDs will be have their risk dismissed!" -f $userCount)
        if ($userCount -gt 60) {
            Write-Verbose ("Paging through {0} Risky Users 60 users per page" -f $userCount)
            $processed = 0
            while ($processed -ne $userCount) {
                $pageOfUserIds = $UserIds | Select-Object -skip $processed | Select-Object -first 60

                if ($pscmdlet.ShouldProcess($pageOfUserIds, "Dismiss User Risk")) {
                    Invoke-MgDismissRiskyUser -UserIds $pageOfUserIds
                }

                $processed += $pageOfUserIds.count
                Write-Verbose ("{0} total risky Users Dismissed" -f $processed)
                Write-Information ("{0} total risky Users Dismissed" -f $processed)
            }


        }
        else {
            if ($pscmdlet.ShouldProcess($UserIDs, "Dismiss User Risk")) {
                Invoke-MgDismissRiskyUser -UserIds $UserIds
            }
        }
    }
    end {

        Write-Verbose ("{0} total risky Users Dismissed" -f $userCount)
        Write-Verbose "Complete!"
    }
}