# Minikube

Various script to manage Minikube with "none" mode on Ubuntu.

```bash
# to spin Minikube
./start-minikube.sh

# to start Minikube with cri-o as container engine
./start-minikube.sh --with-crio

# open K8S dashboard
./open-dashboard.sh

# to deploy sample apps
./deploy-sample.sh
./deploy-jenkins.sh

# to terminate
./stop-minikube.sh
./delete-minikube.sh
```
