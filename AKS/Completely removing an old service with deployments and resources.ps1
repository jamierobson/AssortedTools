. .\_AKSContextFunctions.ps1
$subscription=''
$clusterResourceGroup=''
$serviceName=''
$clusterName="$clusterResourceGroup-aks" # assuming naming conventions

function Cleanup-OldDeployment() {
param([string]$serviceName)
    kubectl delete deployment $serviceName
    kubectl delete service $serviceName
    kubectl delete issuer $serviceName-issuer
    kubectl delete secret $serviceName-certificate
    kubectl delete secret $serviceName-issuer
    kubectl delete certificate $serviceName-certificate
    kubectl delete ingress $serviceName-ingress
    kubectl delete ingress $serviceName-aks-ingress
    kubectl delete ingress $serviceName-trafficmanager-ingress
    kubectl delete hpa $serviceName
}


Set-SubscriptionTo -name $subscription
az aks get-credentials -g $clusterResourceGroup -n $clusterName
Cleanup-OldDeployment -serviceName $serviceName

Logout-AllClusters
