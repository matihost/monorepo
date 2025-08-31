# EchoServer

Example Helm chart and ArgoCD deployment to deploy echoserver application.

It demonstrate app deployment along with antiAffinity, nodeSelectors, PDB, HPA PSP/securityContext, Ingress exposure, NodePolicy setup etc.

For ArgoCD deployment the [ArgoCD](../../argocd/) needs to be deployed.

## Usage

```bash
# deploys app via Helm to selected environment
make deploy-via-helm ENV=minikube

# deploys app via custom script to selected environment
make deploy-via-script ENV=minikube

# deploy app via ArgoCD Application to selected environment
make deploy-via-argocd ENV=minikube

# test e2e app
make test ENV=minikube

# uninstall application via Helm
make uninstall-helm ENV=minikube
```
