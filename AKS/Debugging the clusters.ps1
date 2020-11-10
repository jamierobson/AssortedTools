. .\_AKSContextFunctions.ps1
$subscription = ""
$clusterResourceGroup=''
$clusterName="$clusterResourceGroup-aks" # assuming a naming convention

az login
Set-SubscriptionTo -name $subscription
az aks get-credentials -g $clusterResourceGroup -n $clusterName

<#Your commands here#>

Logout-AllClusters



<#
# Sample things we could be interested in
az aks -h
helm -h
kubectl -h
kubectl api-resources
helm list -n ingress
kubectl get namespaces
kubectl get certificates
kubectl get challenges
kubectl get service,deployments proposalfeedbackserviceapi
kubectl get service,deployments proposalfeedbackserviceagent
#>

<#
# Update nginx
$publicIpName="$clusterResourceGroup-ip"
$ipAddress=(az network public-ip show -g $clusterResourceGroup -n $publicIpName --subscription $createClusterInSubscriptionId | ConvertFrom-Json).ipAddress
helm list -n ingress
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo update
helm upgrade nginx-ingress --namespace ingress stable/nginx-ingress --set controller.service.loadBalancerIP=$ipAddress --set controller.replicaCount=1 --set controller.service.externalTrafficPolicy='Local'
helm list -n ingress
#>


<#

az aks
helm list --all-namespaces
kubectl api-resources


kubectl get ingress
kubectl <get|edit|...> ingress <ingressname>
kubectl get certificate
kubectl get challenges

kubectl get pods
kubectl delete pod <podname>

kubectl get services
kubectl delete service <servicename>

kubectl top node
kubectl top pod

kubectl describe <resourcetype> <resourcename>
#>




#kubectl delete certificate metadataserviceapi-aks-certificate
#kubectl delete certificate caseconsentsserviceapi-aks-certificate
#kubectl delete certificate productofferingcatalogapi-aks-certificate
#kubectl delete certificate treatmentproposalserviceapi-aks-certificate
#kubectl delete certificate orderformserviceapi-aks-certificate
#modelserviceapi-aks-certificate