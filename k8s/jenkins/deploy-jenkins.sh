#!/usr/bin/env bash
[ -x /usr/local/bin/helm ] || (\
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash; \
helm repo add stable https://kubernetes-charts.storage.googleapis.com/)

kubectl create ns ci
kubectl config set-context --current --namespace=ci
helm install ci stable/jenkins -f configuration.yaml


while [ "`kubectl get svc ci-jenkins -n ci -o jsonpath="{.status..ip}"| xargs`" == "" ]; do
  echo "Waiting for LoadBalancer for Jenkins..."; sleep 1
done

echo "Jenkins Url: http://$(kubectl get svc ci-jenkins -n ci -o jsonpath="{.status..ip}")"
echo "User: admin Password: $(kubectl get secret --namespace ci ci-jenkins -o jsonpath="{.data.jenkins-admin-password}" | base64 --decode)"