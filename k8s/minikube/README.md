# Minikube

Various script to manage Minikube with "none" mode on Ubuntu.

Tested environment:

* Ubuntu 22.10

* CNI: Cilium v1.12.6

* Minikube 1.29.0 (and K8S 1.26.1)

And CRI:

* Docker 20.10.16 + cri-dockerd 0.3.1

Or

* Containerd 1.6.4-0ubuntu1.1

Or

* CRIO 1.26.1~0

Tested working configurations:

* `./start-minikube.sh`  - starts Minikube wiht containerd with none driver

* `./start-minikube.sh --with-containerd`

* `./start-minikube.sh --with-docker`

* `./start-minikube.sh --with-crio`

Samples:

```bash
# start Minikube with docker minimum set of features (PSP, Nginx Ingress)
start-minikube.sh --with-docker

# creates PV being a dir under /tmp, useful for creating PV for Minikube
make create-hostPath-pv PV=pvname NS=namespace

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
cd ../apps/echoserver && make deploy-minikube

# to terminate
./stop-minikube.sh
./delete-minikube.sh

```
