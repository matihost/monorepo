# Minikube

Various script to manage Minikube with "none" mode on Ubuntu.

Samples:

```bash
# start Minikube with docker minimum set of features (PSP, Nginx Ingress)
start-minikube.sh --with-docker

# start Minikube with docker maxmimum set of features (PSP, Nginx Ingress, NetworkPolicy via CNI/Cilium, Istio, Gatekeeper)
start-minikube.sh --with-docker --with-cni --with-gatekeeper --with-istio

# start with Crio as container engine (implies CNI aka enables NetworkPolicy)
start-minikube.sh --with-crio

# start with Crio as container engine with Istio
start-minikube.sh --with-crio --with-istio

# open K8S dashboard
./open-dashboard.sh

# to deploy sample apps
# deploy sample echoserver app via kubectl commands
./scripts/deploy-sample-app.sh

# deploy same app via Helm charts
./apps/echoserver/deploy.sh

# to terminate
./stop-minikube.sh
./delete-minikube.sh
```
