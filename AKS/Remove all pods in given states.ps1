. .\_AKSContextFunctions.ps1
$subscription = ""
$clusterResourceGroup=''
$clusterName="$clusterResourceGroup-aks"

LoginIfRequired
Set-SubscriptionTo -name $subscription
az aks get-credentials -g $clusterResourceGroup -n $clusterName

$allPods = kubectl get pods --no-headers=true -o json | ConvertFrom-Json
$containersInWaitingState = $allPods.items | where-Object { $_.status.containerStatuses.state -like '*waiting*' }
$containersInCrashLoopBackoff = $containersInWaitingState | Where-Object {$_.status.containerStatuses.state.waiting.reason -eq 'CrashLoopBackOff'}


$containersInTerminatedState = $allPods.items | where-Object { $_.status.containerStatuses.state -like '*terminated*' }
$containersInTerminatedState | write-host

$containersInCrashLoopBackoff | ForEach-Object {
    kubectl delete po $_.metadata.name
}

Logout-AllClusters
