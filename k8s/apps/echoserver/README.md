# EchoServer

Example Helm chart to deploy echoserver application.
It demonstrate app deployment along with antiAffinity, nodeSelectors, PDB, HPA PSP/securityContext, Ingress exposure, NodePolicy setup etc.

## Installation

### Prerequisites

Namespace to deploy to

```bash
  kubectl create ns learning
  kubectl config set-context --current --namespace learning
```

Certificate

```bash
openssl req -x509 -sha256 -nodes -days 365 -subj "/CN=echoserver.learning.testing" -newkey rsa:2048 -keyout /tmp/echoserver.learning.testing.key -out /tmp/echoserver.learning.testing.crt
```

### Deployment

```bash
# to see what is goint to be deployed
helm template  echoserver . -n learning --debug --set ingress.tls.crt=$(base64 -w 0 /tmp/echoserver.learning.testing.crt) --set ingress.tls.key=$(base64 -w 0 /tmp/echoserver.learning.testing.key)
```

```bash
# actual deployment (install or upgrade) in namespace learning
helm upgrade --install  echoserver . -n learning --set ingress.tls.crt=$(base64 -w 0 /tmp/echoserver.learning.testing.crt) --set ingress.tls.key=$(base64 -w 0 /tmp/echoserver.learning.testing.key)
```

### Local development under Minikube

```bash
# deploy echoserver on minikube via Helm
make deploy-minikube

# deploys echoserver on minikube via bash script (kubectl apply)
make deploy-minikube-via-script

# smoke test echoserver app deployment on minikube
make test-minikube
```
