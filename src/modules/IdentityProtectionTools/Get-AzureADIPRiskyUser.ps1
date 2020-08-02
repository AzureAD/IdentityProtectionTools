<#
.SYNOPSIS
    Retrieves the users who are currently identified as RiskyUsers by Identity Protection
.DESCRIPTION
    Retrieves the users who are currently identified as RiskyUsers by Identity Protection
.EXAMPLE
     $riskyUsers = Get-AzureADIPRiskyUser -RiskLevel high -Verbose  -All -asUserIds
     Get All High Risk Users updated in the last day as a collection of User ObjectIDs
.EXAMPLE
     $riskyUsers = Get-AzureADIPRiskyUser -RiskLevel high -Verbose  -All -asUserIds
     Get all users with elevated risk that was updated in the last day as a collection of User ObjectIDs
.EXAMPLE
    $riskyUsers = Get-AzureADIPRiskyUser -RiskLevel high -Verbose  -All -asUserIds -riskUpdatedSinceDays -30
    Get all High Risk users with their risk updated in the last 30 days as a collection of User ObjectIDs
.EXAMPLE
    $riskyUsers = Get-AzureADIPRiskyUser -RiskLevel high -Verbose  -All -asUserIds -riskUpdatedSinceDays -30
    Invoke-AzureADIPDismissRiskyUser -UserIds $riskyUsers -Verbose

    Retrieve the Risky Users and then dismiss their risk

.INPUTS
    Inputs to this cmdlet (if any)
.OUTPUTS
    Output from this cmdlet (if any)
.NOTES
    Information on calling the MS Graph API for Identity Protection can be found at:  https://docs.microsoft.com/azure/active-directory/identity-protection/howto-identity-protection-graph-api
    Permissions Scopes Needed for Read are defined in the above documentation
#>
function Get-AzureADIPRiskyUser {
    [CmdletBinding(DefaultParameterSetName = 'Default',
        HelpUri = 'https://github.com/AzureAD/IdentityProtectionTools/')]
    [OutputType([String])]
    Param (
        # Limit Results by RiskLevel of High, Medium, Low, or NotNone
        [Parameter(Mandatory = $False,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        [ValidateSet("low", "medium", "high", "NotNone")]
        $RiskLevel,
        [Parameter(Mandatory = $False,
            Position = 1,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        # The days ago that the risk was last updated expressed in negative days (-30 for 30 Days Ago)
        [int]
        $riskUpdatedSinceDays,
        [Parameter(Mandatory = $False,
            Position = 2,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false)]
        # Return all results for Query. By default the RiskyUsers API will retrieve the first page of results which defaults to 100 objects to page.  Specifying the -All switch returns all pages of the query results.
        [switch]
        $All,

        [string]
        # OData Filter to pass to the RiskyUsers API
        [Parameter(Mandatory = $False,
            Position = 3,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'Filtered Query')]
        $Filter,
        # Return results as a collection of ObjectIds for the query results
        [switch]
        $asUserIds
    )
    begin {

        $apiPermissionScopes = @("IdentityRiskyUser.Read.All")

        if ($null -eq (Get-MgContext)) {
            Write-Error "Please Connect to MS Graph API with the Connect-Graph cmdlet from the Microsoft.Graph.Authentication module first before calling functions!" -ErrorAction Stop
        }
        else {
            if ($false -eq ((Get-MgContext).Scopes.Contains("IdentityRiskyUser.Read.All"))) {
                Write-Error "Current MS Graph Context does not contain the IdentityRiskyUser.Read.All scope required to call the IdentityProtection riskyUsers API.  Please ensure you are connecting with an identity that has this permission scope!" -ErrorAction Stop
            }

        }
    }
    process {
        $ParamCollection = @{}
        $filterBuilder = $null


        if ($All) {
            $ParamCollection.All = $All
        }

        if ($null -notLike $Filter) {
            Write-Verbose ("Retrieving RiskyUsers with custom Filter {0}" -f $Filter)
            $ParamCollection.Filter = $Filter
        }
        else {

            if ($null -ne $RiskLevel) {

                Write-Verbose ("Retrieving RiskyUsers with RiskLevel of {0}" -f $RiskLevel)
                $filterRiskLevel = $null

                if ($RiskLevel -eq 'NotNone') {
                    $filterRiskLevel = "(RiskLevel ne 'none')"
                }
                else {
                    $filterRiskLevel = "(RiskLevel eq '$RiskLevel')" -f $RiskLevel
                }
                $filterBuilder = $filterRiskLevel
            }

            if ($null -notlike $riskUpdatedSinceDays) {
                Write-Verbose ("Retrieving RiskyUsers who had their risk updated since {0} days" -f $riskUpdatedSinceDays)
                $filterDate = ("(riskLastUpdatedDateTime gt {0})" -f (Get-Date (get-date).AddDays($riskUpdatedSinceDays) -UFormat %Y-%m-%dT00:00:00Z))
                if ($null -eq $filterBuilder) {
                    $filterBuilder = $filterDate
                }
                else {
                    $filterBuilder = "{0} and {1}" -f $filterRiskLevel, $filterDate
                }
            }

            if ($null -notlike $filterBuilder) {
                Write-Verbose ("Retrieving RiskyUsers with Filter {0}" -f $filterBuilder)
                $ParamCollection.Filter = $filterBuilder
            }

        }
        $RiskyUsers = Get-MgRiskyUser @ParamCollection
    }
    end {
        if ($null -eq $RiskyUsers) {
            $riskyUsersCount = 0
        }
        else {
            $riskyUsersCount = $RiskyUsers.count
            
            if ($asUserIds) {
                Write-Output $RiskyUsers.Id
            }
            else {
                Write-Output $RiskyUsers
            }
        }
        Write-Verbose ("{0} Risky Users Retrieved!" -f ($riskyUsersCount))
        
    }
}