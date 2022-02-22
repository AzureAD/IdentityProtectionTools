---
page_type: sample
languages:
- powershell
products:
- AzureActiveDirectory
description: "Sample PowerShell module and scripts for automating activities for the Azure Active Directory Identity Protection services API"
urlFragment: "update-this-to-unique-url-stub"
---

# Sample

<!-- 
Guidelines on README format: https://review.docs.microsoft.com/help/onboard/admin/samples/concepts/readme-template?branch=master

Guidance on onboarding samples to docs.microsoft.com/samples: https://review.docs.microsoft.com/help/onboard/admin/samples/process/onboarding?branch=master

Taxonomies for products and languages: https://review.docs.microsoft.com/new-hope/information-architecture/metadata/taxonomies?branch=master
-->

The Identity Protection Tools PowerShell module contains sample functions for:

- Enumerating Risky Users by RiskLevel and date when their risk was last updated
- Dismissing Risk for selected users for bulk operations
- Confirming Compromise for selected users for bulk operations

## Contents

Outline the file contents of the repository. It helps users navigate the codebase, build configuration and any related assets.

| File/folder       | Description                                |
| ----------------- | ------------------------------------------ |
| `src`             | Sample source code.                        |
| `.gitignore`      | Define what to ignore at commit time.      |
| `CHANGELOG.md`    | List of changes to the sample.             |
| `CONTRIBUTING.md` | Guidelines for contributing to the sample. |
| `README.md`       | This README file.                          |
| `LICENSE`         | The license for the sample.                |

## Prerequisite

The IdentityProtectionTools is utilizing the [Microsoft Graph PowerShell SDK module](https://docs.microsoft.com/en-us/graph/powershell/installation) for connecting and managing sessions with the Microsoft Graph API.

1. Install the following modules from the PowerShell Gallery which are used to execute the logic in this module where you intend to run the module functions

- [Microsoft.Graph.Authentication](https://www.powershellgallery.com/packages/Microsoft.Graph.Authentication)
- [Microsoft.Graph.Identity.SignIns](https://www.powershellgallery.com/packages/Microsoft.Graph.Identity.SignIns/)

```ps
Install-module Microsoft.Graph.Authentication,Microsoft.Graph.Identity.SignIns
```

1. For the user that you intend to invoke the commands against the [Identity Protection RiskyUsers API](https://docs.microsoft.com/graph/api/resources/identityprotectionroot) you will need the following permissions granted

- Listing riskyUsers
  - IdentityRiskyUser.Read.All
- Dismissing User Risk
  - IdentityRiskyUser.ReadWrite.All

**Note**: You will need to consent to the Microsoft Graph SDK PowerShell nodule in the tenant to use it to invoke Connect-Graph.

## Setup

1. Download the Identity Protection Tools PowerShell Module from this repo
2. From where you extracted the files, Import the module into your PowerShell Session
**Note:** Please do not use the ISE to run this sample
```ps
Import-module .\IdentityProtectionTools.psd1
```

## Running the sample

1. Connect to the MS Graph endpoint with the proper permission scopes.  

```ps
$apiPermissionScopes = @("IdentityRiskyUser.Read.All", "IdentityRiskyUser.ReadWrite.All")
Connect-Graph -Scopes $apiPermissionScopes
```
**Note:** For connecting as user identities, it will use the device flow using your browser.

2. Enumerate users in the connected tenant which are a risky Users

    -  You can specify the RiskLevel as:
       -  low
       -  medium
       -  high
       -  notnone (includes low,medium,high)
    - Days since risk was updated
      - -30 for updated in the last 30 days

```ps
Get-AzureADIPRiskyUser -RiskLevel High -All
```

3. Dismiss User Risk for collection of User IDs

```ps
Invoke-AzureADIPDismissRiskyUser -UserIds $CollectionOfUsersIDs
```

**Note:** The riskyUsers API supports dismissing risk a page of 60 users at a time, which the sample will page through to completion.
   

## Key concepts

The Identity Protection sample module is an example of utilizing the Microsoft Graph API for bulk operations.

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
