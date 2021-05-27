. .\_AKSContextFunctions.ps1

[string]$subscription = '';
[string]$resourceGroupName = '';
[string]$vaultName = '';

class NamedSecret {
    
    [PSCustomObject]$Secret
    [string] $Name
    [string] $Vault;

    NamedSecret([PSCustomObject]$secret) {
        $this.Secret = $secret;
        $this.Name = Parse-SecretName -secretId $secret.id;
        $this.SetVault();
    }

    SetVault() {
        $protocolIdentifier = '://';
        $protocolIndex = $this.Secret.id.IndexOf($protocolIdentifier);
        $withoutProtocol = $this.Secret.id.Substring($protocolIndex + $protocolIdentifier.Length, ($this.Secret.id.Length - $protocolIndex - $protocolIdentifier.Length));
        $this.Vault = $withoutProtocol.Substring(0, $withoutProtocol.IndexOf('.'));
    }
}

class RenameSecret {

    [NamedSecret]$Named
    [string]$NewName

    RenameSecret([NamedSecret]$secret, [string]$newName) {
        $this.Named = $secret;
        $this.NewName = $newName;
    }

    Rename() {
        $secretValue = ((az keyvault secret show --id $this.Named.Secret.Id) | ConvertFrom-Json).Value
        az keyvault secret set -n $this.NewName --vault-name $this.Named.Vault --value $secretValue --tags ""
        az keyvault secret delete --id $this.Named.Secret.Id
    }
}

function Parse-SecretName {
param([string]$secretId)
    $secretIdSectionToStringIdentifyingString = "/secrets/";
    $secretIdTextToStrip = $secretId.Substring(0, $secretId.IndexOf($secretIdSectionToStringIdentifyingString) + $secretIdSectionToStringIdentifyingString.Length);
    $secretName = $secretId.Replace($secretIdTextToStrip, '')
    return $secretName;
}

function Get-RenameSecret(){
param([PsCustomObject]$secretReferences, [string]$name, [string]$newKeyName)
    return $secretReferences | ForEach-Object { [NamedSecret]::new($_) } | Where-Object { $_.Name.StartsWith($name) } | ForEach-Object {
        [RenameSecret]::new($_, $newKeyName)
    }
}

LoginIfRequired
Set-SubscriptionTo -name $subscription
if ((az group exists -n $resourceGroupName) -eq 'false') { write-host "Resource group $resourceGroupName does not exist in subscription $desiredSubscription. Aborting"; exit; }

$vault = (az keyvault list -g $resourceGroupName) | ConvertFrom-Json | Where-Object {$_.name -eq $vaultName}
$secretReferences = (az keyvault secret list --vault-name $vaultName) | ConvertFrom-Json

if($secretReferences -eq $null){
    write-host "Could not access vault, or nothing to work with. Aborting";
    exit;
}

$secretsToRename = [System.Collections.ArrayList[RenameSecret]]@()

$newAmericaReanmeSecrets = Get-RenameSecretWithSpecificFormat -secretReferences $secretReferences -regionShorthand "" -regionLonghand "";
$secretsToRename.Add((Get-RenameSecret -secretReferences $secretReferences -name "" -newKeyName "")) > $null;

$secretsToRename.Rename();