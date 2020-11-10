. .\_AKSContextFunctions.ps1

$subscription = ""
$clusterResourceGroup=''
$clusterName="$clusterResourceGroup-aks" # assuming a naming convention

az login

Set-SubscriptionTo -name $subscription
az aks get-credentials -g $clusterResourceGroup -n $clusterName

helm list -n ingress
helm repo update
helm search repo -l jetstack/cert-manager

helm uninstall cert-manager -n cert-manager
kubectl delete role cert-manager-cainjector:leaderelection -n kube-system
kubectl delete role cert-manager:leaderelection -n kube-system
kubectl delete role cert-manager-webhook:dynamic-serving -n cert-manager

kubectl delete rolebinding cert-manager-cainjector:leaderelection -n kube-system
kubectl delete rolebinding cert-manager:leaderelection -n kube-system
kubectl delete rolebinding cert-manager-webhook:dynamic-serving -n cert-manager

kubectl delete serviceaccount cert-manager-cainjector -n cert-manager
kubectl delete serviceaccount cert-manager -n cert-manager
kubectl delete serviceaccount cert-manager-webhook -n cert-manager

kubectl delete service cert-manager -n cert-manager
kubectl delete service cert-manager-webhook -n cert-manager
kubectl delete service cert-manager-cainjector -n cert-manager

kubectl delete deployment cert-manager -n cert-manager
kubectl delete deployment cert-manager-webhook -n cert-manager
kubectl delete deployment cert-manager-cainjector -n cert-manager

kubectl delete clusterrole cert-manager-cainjector
kubectl delete clusterrole cert-manager-edit
kubectl delete clusterrole cert-manager-controller-clusterissuers
kubectl delete clusterrole cert-manager-controller-issuers
kubectl delete clusterrole cert-manager-controller-orders
kubectl delete clusterrole cert-manager-controller-challenges
kubectl delete clusterrole cert-manager-controller-certificates
kubectl delete clusterrole cert-manager-controller-controller-certificates
kubectl delete clusterrole cert-manager-controller-ingress-shim
kubectl delete clusterrole cert-manager-view

kubectl delete clusterrolebinding cert-manager-cainjector
kubectl delete clusterrolebinding cert-manager-edit
kubectl delete clusterrolebinding cert-manager-controller-clusterissuers
kubectl delete clusterrolebinding cert-manager-controller-issuers
kubectl delete clusterrolebinding cert-manager-controller-orders
kubectl delete clusterrolebinding cert-manager-controller-challenges
kubectl delete clusterrolebinding cert-manager-controller-certificates
kubectl delete clusterrolebinding cert-manager-controller-ingress-shim
kubectl delete clusterrolebinding cert-manager-view

kubectl delete MutatingWebhookConfiguration cert-manager-webhook
kubectl delete ValidatingWebhookConfiguration cert-manager-webhook

$certManagerSecrets = kubectl get secret -n cert-manager
$certManagerSecrets | ForEach-Object { $secretName = $_.Substring(0, $_.IndexOf(' ')); if($secretname -ne "NAME"){ kubectl delete secret $secretName -n cert-manager } }

#kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager-legacy.crds.yaml
helm upgrade cert-manager jetstack/cert-manager -n cert-manager --install --force
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.0/cert-manager.crds.yaml

# can deploy your software now, assuming ingress' have been updated


Logout-AllClusters