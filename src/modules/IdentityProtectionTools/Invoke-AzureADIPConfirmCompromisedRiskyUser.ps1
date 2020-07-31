<#
.SYNOPSIS
    Confirm a user as compromized in the Azure AD Identity Protection service
.DESCRIPTION
    Confirm a user as compromized in the Azure AD Identity Protection service
.EXAMPLE
    Invoke-AzureADIPConfirmCompromisedRiskyUser -UserIds @UserIdstoDismissRisk
    Mark the ObjectIDs as a Confirmed Compromised Risky User
.EXAMPLE
    Invoke-AzureADIPConfirmCompromisedRiskyUser -UserIds @UserIdstoDismissRisk -Confirm:$false
    Mark the ObjectIDs as a Confirmed Compromised Risky User
.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    Parameters should be passed in as a collection of User ObjectIDs
    By default the Confirm Impact is High
#>
function Invoke-AzureADIPConfirmCompromisedRiskyUser {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        SupportsShouldProcess = $true,
        PositionalBinding = $false,
        HelpUri = 'https://github.com/AzureAD/IdentityProtectionTools/',
        ConfirmImpact = 'High')]
    [Alias()]
    [OutputType([String])]
    Param (
        # ObjectIDs of the users to Confirm as Compromised
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
        Write-Verbose ("{0} User ObjectIDs will have their risk confirmed as compromised!" -f $userCount)
        Write-Information ("{0} User ObjectIDs will have their risk confirmed as compromised!" -f $userCount)
        if ($userCount -gt 60) {
            Write-Verbose ("Paging through {0} Users 60 users per page" -f $userCount)
            $processed = 0
            while ($processed -ne $userCount) {
                $pageOfUserIds = $UserIds | Select-Object -skip $processed | Select-Object -first 60

                if ($pscmdlet.ShouldProcess($pageOfUserIds, "Confirm As Compromised")) {
                    Confirm-MgRiskyUserCompromised -UserIds $pageOfUserIds
                }
                $processed += $pageOfUserIds.count
                Write-Verbose ("{0} total Users Confirmed as Compromised" -f $processed)
                Write-Information ("{0} total  Users Confirmed as Compromised" -f $processed)
            }
        }
        else {
            if ($pscmdlet.ShouldProcess($UserIDs, "Confirm As Compromised")) {
                Confirm-MgRiskyUserCompromised -UserIds $UserIds
            }
        }
    }
    end {

        Write-Verbose ("{0} total risky Users confirmed As Compromised" -f $userCount)
        Write-Verbose "Complete!"
    }
}