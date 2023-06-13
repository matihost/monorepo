# Minikube

Various script to manage Minikube with "none" mode on Ubuntu.

Tested environment:

* Ubuntu 23.04

* CNI: Cilium v1.13.3

* Minikube 1.30.1 (and K8S 1.26.3)

And CRI:

* Docker 20.10.21 + cri-dockerd 0.3.1

Or

* Containerd 1.6.12-0ubuntu3

Or

* CRIO 1.27.0

Tested working configurations:

* `./start-minikube.sh`  - starts Minikube with Docker with Cilium CNI driver

* `./start-minikube.sh --with-docker --with-cillium`

Untested/not-working configurations:

* `./start-minikube.sh --with-containerd` - does not work

* `./start-minikube.sh --with-crio` - not tested

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
