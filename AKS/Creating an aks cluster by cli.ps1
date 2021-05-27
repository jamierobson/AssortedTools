. .\_AKSContextFunctions.ps1

# az login #if we haven't already. This is mostly a one time per session on a cli

$createClusterInSubscription=''
$containerRegistrySubscriptionId=''
$containerResourceGroup=''
$createClusterInSubscriptionId=''
$clusterResourceGroup=''

#Assuming naming conventions here
$clusterName="$clusterResourceGroup-aks"
$publicIpName="$clusterResourceGroup-ip"
$publicIpDns=$clusterName
$keyVaultName="$clusterResourceGroup-kv" -replace "-", ''
$analyticsName="$clusterName-analytics"
$servicePrincipalName=$clusterName
$servicePrincipalNameKeyVaultEntryName="$servicePrincipalName-principal-name"
$servicePrincipalIdKeyVaultEntryName="$servicePrincipalName-principal-id"
$servicePrincipalSecretKeyVaultEntryName="$servicePrincipalName-principal-secret"

#Assuming node pool settings here
$kubernetesVersion='1.14.8'
$nodeVmSize='Standard_DS2_v2'
$minNodeCount=2
$maxNodeCount=4

# Change this according to naming convension mapped to regional needs
if($clusterResourceGroup.StartsWith("eu-")) { $location = "northeurope" } `
elseif($clusterResourceGroup.StartsWith("am-")) { $location = "eastus" } `
elseif($clusterResourceGroup.StartsWith("as-")) { $location = "eastasia" }
$location

LoginIfRequired
Set-SubscriptionTo -name $createClusterInSubscription


# Create basic resources
az group create -g $clusterResourceGroup -l $location --subscription $createClusterInSubscriptionId

az keyvault create -n $keyVaultName -g $clusterResourceGroup -l $location --subscription $createClusterInSubscriptionId
$publicIp=az network public-ip create --name $publicIpName --resource-group $clusterResourceGroup --subscription $createClusterInSubscriptionId --dns-name $publicIpDns --sku Basic --allocation-method static | ConvertFrom-Json
$ipAddress=$($publicIp.publicIp).ipAddress

# Service Principal
$servicePrincipal=$servicePrincipal=az ad sp create-for-rbac -n $servicePrincipalName --role contributor --years 300 --scopes /subscriptions/$createClusterInSubscriptionId/resourceGroups/$clusterResourceGroup /subscriptions/$containerRegistrySubscriptionId/resourceGroups/$containerResourceGroup | ConvertFrom-Json

az keyvault secret set -n $servicePrincipalNameKeyVaultEntryName --vault-name $keyVaultName --value $servicePrincipalName
az keyvault secret set -n $servicePrincipalIdKeyVaultEntryName --vault-name $keyVaultName --value $servicePrincipal.appId
az keyvault secret set -n $servicePrincipalSecretKeyVaultEntryName --vault-name $keyVaultName --value $servicePrincipal.password

# Create the cluster
az aks create --resource-group $clusterResourceGroup  --subscription $createClusterInSubscriptionId --name $clusterName --location $location --kubernetes-version $kubernetesVersion --node-vm-size $nodeVmSize --service-principal $($servicePrincipal.appId) --client-secret $($servicePrincipal.password) --load-balancer-sku basic --vm-set-type VirtualMachineScaleSets --enable-cluster-autoscaler --node-count $minNodeCount --min-count $minNodeCount --max-count $maxNodeCount --generate-ssh-keys

# Configure nginx to ensure that the cluster can accept traffic
az aks get-credentials -g $clusterResourceGroup -n $clusterName --subscription $createClusterInSubscriptionId # Can also use aks switch if using the secure terminal
$ipAddress=(az network public-ip show -g $clusterResourceGroup -n $publicIpName --subscription $createClusterInSubscriptionId |ConvertFrom-Json).ipAddress
kubectl create ns ingress
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install nginx-ingress --namespace ingress stable/nginx-ingress --set controller.service.loadBalancerIP=$ipAddress --set controller.replicaCount=1 --set controller.service.externalTrafficPolicy='Local'
kubectl annotate service nginx-ingress-controller -n ingress service.beta.kubernetes.io/azure-load-balancer-resource-group=$clusterResourceGroup

# Configure the certification manager
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.10/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
kubectl label namespace cert-manager certmanager.k8s.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager --namespace cert-manager --version v0.10.0 jetstack/cert-manager

# Configure monitoring
$skuJson = '{"sku":""}' | ConvertTo-Json
az resource create --resource-type=Microsoft.OperationalInsights/workspaces -g $clusterResourceGroup --subscription $createClusterInSubscriptionId -n $analyticsName -l $location -p $skuJson
$workspaceId = az resource show -g $clusterResourceGroup -n $analyticsName --subscription $createClusterInSubscriptionId --resource-type=Microsoft.OperationalInsights/workspaces --query "[id]" -o tsv
az aks enable-addons -a monitoring -g $clusterResourceGroup -n $clusterName --workspace-resource-id $workspaceId
kubectl config delete-context $clusterName

#Verify - give it 5 minutes. Will need to connect to the cluster again. If helm list fails with a security error, then might need to follow advice from https://stackoverflow.com/a/46688254
#az aks get-credentials -g $clusterResourceGroup -n $clusterName --subscription $createClusterInSubscriptionId
helm list -n ingress	
kubectl describe svc nginx-ingress-controller -n ingress

Logout-AllClusters