. .\_AKSContextFunctions.ps1
$subscription = '';
$clusterResourceGroup=''
$match=''
$clusterName="$clusterResourceGroup-aks" #assume naming convention

LoginIfRequired
Set-SubscriptionTo -name $subscription
az aks get-credentials -g $clusterResourceGroup -n $clusterName
$asda = kubectl get pods
$asda | ForEach-Object {
    if($_.Contains($match)) {
        $pod = $_.Substring(0, $_.IndexOf(' '))
        kubectl delete pod $pod
    }
}

Logout-AllClusters
