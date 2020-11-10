function ProtectAgainst-AccidentalProductionAccess {
[CmdletBinding()]param([Parameter(ValueFromPipeline)]$subscriptionName)

    # This function will add a small challenge to encourage a developer 
    # to realise that the actions they are about to perform are against a production cluster
    # Add names of all your production subscriptions here. 
    $productionSubscriptions = @("", "") 

    if ($productionSubscriptions -icontains $subscriptionName)
    {
        $matchThis = [Guid]::NewGuid().ToString().Substring(0, 3);
        $confirmationInput = read-host -Prompt "Type the following to continue with this action on production $matchThis";
        if ($matchThis -ne $confirmationInput) {
            Write-Host "Production check not passed. Exiting script";
            exit;
        }
    }
}

function Set-SubscriptionTo {
param([string]$name)
    $name | ProtectAgainst-AccidentalProductionAccess;
    $activeSubscriptionName = (az account show | ConvertFrom-Json).Name;

    if($name -eq $activeSubscriptionName){
        return;
    }

    $subscriptionListString = az account list --all;
    $subscriptionList = $subscriptionListString | ConvertFrom-Json;
    $subscriptionList | ForEach-Object {
        if($_.Name -eq $name)
        {
            az account set -s $_.id;
            continue;
        }
    }
}

function Logout-AllClusters {
    $availableContexts = kubectl config get-contexts -o name
    $availableContexts | ForEach-Object { kubectl config delete-context $_ }
}