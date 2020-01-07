K8S_CONTEXT=$(kubectl config current-context 2>/dev/null) 
minikube delete 2>/dev/null 
if [ "${K8S_CONTEXT}" = "minikube" ]; then 
  kubectl config unset current-context &>/dev/null 
fi 
kubectl config delete-context minikube &>/dev/null 