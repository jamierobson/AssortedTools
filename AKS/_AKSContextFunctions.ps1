function Get-ProductionSubscriptions {
    return @("")
}

function LoginIfRequired {
    $showAccountResponse = az account show
    if (!$showAccountResponse){
        az login
    }
}

function ProtectAgainst-AccidentalProductionAccess {
[CmdletBinding()]param([Parameter(ValueFromPipeline)]$subscriptionName)
    $productionSubscriptions = Get-ProductionSubscriptions 
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