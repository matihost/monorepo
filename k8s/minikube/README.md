# Minikube

Various script to manage Minikube with "none" mode on Ubuntu.

Dependency versions the script is set up for:

* Ubuntu 26.04 LTS / 26.10

* Minikube 1.39.0 (and K8S 1.37), `--driver=none`

* CNI: Cilium Helm chart 1.20.3

And CRI:

* Docker 29.x + cri-dockerd 0.4.9 (the `.deb` for the newest Ubuntu is not published, `noble` one is used)

Or

* Containerd

Or

* CRIO 1.37 (`CRIO_VERSION` in the script, matches `versions.crio` in `ansible/system`)

Tested working configurations:

* `./start-minikube.sh`  - starts Minikube with Docker with Cilium CNI driver

* `./start-minikube.sh --with-docker`

* `./start-minikube.sh --with-containerd`

* `./start-minikube.sh --with-crio`

Samples:

```bash
# start Minikube with containerd with minimum set of features (Nginx Ingress)
start-minikube.sh
# start Minikube with docker with minimum set of features (Nginx Ingress)
start-minikube.sh --with-docker

# creates PV being a dir under /tmp, useful for creating PV for Minikube
make create-hostPath-pv PV=pvname NS=namespace

# start Minikube with docker maxmimum set of features (Nginx Ingress, NetworkPolicy via CNI/Cilium, Istio, Gatekeeper)
start-minikube.sh --with-docker --with-gatekeeper --with-istio

# start with Crio as container engine (implies CNI aka enables NetworkPolicy)
start-minikube.sh --with-crio

# start with Crio as container engine with Istio
start-minikube.sh --with-crio --with-istio

# open K8S dashboard
./open-dashboard.sh


# to deploy sample apps
cd ../apps/echoserver && make deploy-via-helm ENV=minikube

# to terminate
./stop-minikube.sh
./delete-minikube.sh
```
