#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || {
  echo "Only Ubuntu supported"
  exit 1
}

function usage() {
  echo -e "Usage: $(basename "$0") [-h|--help|help] [--with-containder|containerd|c] [--with-crio|crio] [--with-docker | docker | d] [--with-cni] [--with-version stable/latest/x.x.x] [--with-nginx | nginx] [--with-istio | istio] [--with-gatekeeper | gatekeeper] [--with-psp | psp]

Starts Minikube in bare / none mode. Assumes latest Ubuntu.

Minimum set of features enabled in every Minikube:
- Container runtime selection (--with-containerd, --with-crio, --with-docker) - by default docker is selected along with --with-cilium.
- Minikube Tunnel Loadbalancer along with Nginx Ingress
- Nginx Ingress Class (--with-nginx) - installs Ngnix Ingress Class
- Registry, Dashboard
- NetworkPolicy via CNI/Cilium (for docker container engine it has to be explicitely defined with either --with-cni or --with-cilium)

Optional features:
- K8S Version (--with-version) - default to stable, possible values: stable, latest, same as Minikube's --kubernetes-version

Optional deprecated features:
- Istio (--with-istio) - install base Istio w/o meaningful config, go to k8s/istio dir to install istio fully
- OPA Gatekeeper (--with-gatekeeper) - install base Gatekeeper w/o meaningful config, go to k8s/gatekeeper dir to install OPA Gatekeeper fully

Samples:
# start default bare/none driver Minikube with containerd with CNI enablement (Cilium installed via Helm)
$(basename "$0")

# start Minikube with docker with CNI/Cilium enablement (Cilium installed via Minikube addon)
$(basename "$0") --with-docker --with-cilium

# start Minikube with docker
$(basename "$0") --with-docker

# start Minikube with containerd with K8S latest version (default: stable)
$(basename "$0") --with-containerd --with-version latest

# start with Crio as container engine
$(basename "$0") --with-crio

# start with Crio as container engine with Istio
$(basename "$0") --with-crio --with-gatekeeper
"
}

function ensureMinikubePresent() {
  [ ! -x /usr/bin/minikube ] &&
    sudo apt -y install conntrack &&
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 &&
    chmod +x minikube && sudo mv minikube /usr/bin/
}

function ensureDockerCGroupSystemD() {
  CGROUP_DRIVER=$(docker info -f "{{.CgroupDriver}}" 2>/dev/null || echo 'Docker not running?')
  [ "${CGROUP_DRIVER}" = "systemd" ] || {
    echo -e "Docker invalid status: ${CGROUP_DRIVER}.\nDocker has to be running and its cgroup-driver has to be systemd. Add \"exec-opts\": [\"native.cgroupdriver=systemd\"] to /etc/docker/daemon.json and restart docker service"
    exit 1
  }
}

function ensureCrictlPresent() {
  [ -x /usr/local/bin/crictl ] || (
    CRICTL_VERSION=$(git ls-remote -t https://github.com/kubernetes-sigs/cri-tools.git | cut -d'/' -f3 | sort -n | tail -n 1)
    wget "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
    sudo tar zxvf "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" -C /usr/local/bin
    rm -f "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
  )

  [ -e /etc/containerd/config.toml ] || {
    sudo mkdir -p /etc/containerd
    sudo touch /etc/containerd/config.toml
  }
}
function ensureCriDockerdPresent() {
  [ -x /usr/bin/cri-dockerd ] || (
    # shellcheck disable=SC1091
    . /etc/os-release

    curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest | jq -r ".assets[] |
      select(.name | test(\"ubuntu-${VERSION_CODENAME}_amd64.deb\")) | .browser_download_url" |
      xargs curl -s -L -o "/tmp/cri-dockerd.deb"
    apt install /tmp/cri-dockerd.deb
  )
}

function ensureCrioPresent() {
  CRIO_VERSION=v1.33

  [ -x /usr/bin/crio ] || (
    # shellcheck disable=SC1091
    . /etc/os-release

    curl -fsSL https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
      sudo gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

    echo "deb [signed-by= /etc/apt/keyrings/cri-o-apt-keyring.gpg] https://download.opensuse.org/repositories/isv:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
      sudo tee /etc/apt/sources.list.d/kubernetes.list

    sudo apt-get update -qq
    sudo apt-get install -y cri-o cri-o-runc buildah
  )
  [ -x /opt/cni/bin/bridge ] || (
    sudo apt -y install containernetworking-plugins
  )

  # TODO remove when https://github.com/kubernetes/minikube/issues/15734 fixed
  [ -e /etc/crio/crio.conf.d/02-crio.conf ] || (
    echo '[crio.image]
# pause_image = ""

[crio.network]
# cni_default_network = ""

[crio.runtime]
# cgroup_manager = ""' | sudo tee /etc/crio/crio.conf.d/02-crio.conf >/dev/null
  )

  # minikube uses cilium as CNI provider when crio mode is enabled
  [ "$(helm repo list | grep -c cilium)" -eq 0 ] && {
    helm repo add cilium https://helm.cilium.io/
    helm repo update
  }
}

function ensureIstioctlIsPresent() {
  [ -x ~/.istioctl/bin/istioctl ] || (
    curl -sL https://istio.io/downloadIstioctl | sh -
    echo "export PATH=\$PATH:\$HOME/.istioctl/bin" >>~/.bashrc
    export PATH=$PATH:$HOME/.istioctl/bin
  )
}

function installGatekeeper() {
  [ "$(helm repo list | grep -c gatekeeper)" -eq 0 ] && {
    helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
    helm repo update
  }
  # Set replicas to 1 as for minikube HA for gatekeeper is less important than memory usage
  helm upgrade --install gatekeeper gatekeeper/gatekeeper --set replicas=1 -n gatekeeper-system --create-namespace
}

# minikube addons enable ingress - stopped working for "none" minikube driver
# ingress controlles needs to be installed manually
function addNginxIngress() {
  [ -x /usr/local/bin/helm ] || {
    curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
    helm repo add stable https://charts.helm.sh/stable
    helm repo add nginx-stable https://helm.nginx.com/stable
    helm repo update
  }
  [ "$(helm repo list | grep -c nginx)" -eq 0 ] && {
    helm repo add nginx-stable https://helm.nginx.com/stable
    helm repo update
  }
  [ "$(kubectl config current-context)" == "minikube" ] && {
    helm upgrade --install -f ngnix.values.yaml ingress-nginx nginx-stable/nginx-ingress -n ingress-nginx --create-namespace || {
      echo "Unable to install NGNIX, ngnix / k8s incompatibility? check NGinx Helm"
      exit 1
    }
  }
}

function addDashboardIngress() {
  kubectl get ingress ingress-dashboard -n kubernetes-dashboard --no-headers=false &>/dev/null || (
    CN="dashboard.minikube"
    FILENAME="/tmp/${CN}"
    openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "${FILENAME}.crt" -newkey rsa:2048 -nodes -keyout "${FILENAME}.key"
    kubectl create secret tls ${CN} --key="${FILENAME}.key" --cert="${FILENAME}.crt" -n kubernetes-dashboard

    echo 'apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress-dashboard
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/ingress.class: nginx
    #this redirect to https if try to enter over http
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    #this is required when backend runs over HTTPS
    #nginx.ingress.kubernetes.io/backend-protocol: HTTPS
    #this requiered if want to protect site
    #nginx.ingress.kubernetes.io/whitelist-source-range: <here your public ip>,<here server ip if want access from server>
spec:
  tls:
    - hosts:
      - dashboard.minikube
      secretName: dashboard.minikube
  rules:
  - host: dashboard.minikube
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port:
              number: 80' | kubectl apply -f - -n kubernetes-dashboard
    echo "Minikube Dashboard available under https://dashboard.minikube"
  )
}

ensureMinikubePresent
K8S_VERSION='stable'
MODE='docker'

ADDONS="registry dashboard nginx volumesnapshots csi-hostpath-driver"
EXTRA_PARAMS='--cni=cilium'
export ADMISSION_PLUGINS="NamespaceExists"

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help | help)
    usage
    exit 1
    ;;
  --with-version)
    K8S_VERSION="${2}"
    shift
    ;;
  --with-crio | crio)
    MODE='crio'
    ;;
  --with-containerd | containerd | c)
    MODE='containerd'
    ;;
  --with-docker | docker | d)
    MODE='docker'
    ;;
  --with-cilium)
    EXTRA_PARAMS="${EXTRA_PARAMS} --cni=cilium"
    ;;
  --with-istio | istio)
    ADDONS="${ADDONS} istio"
    ;;
  --with-gatekeeper | gatekeeper)
    ADDONS="${ADDONS} gatekeeper"
    ;;
  *) PARAMS+=("$1") ;; # save it in an array for later
  esac
  shift
done
set -- "${PARAMS[@]}" # restore positional parameters

case "${MODE}" in
crio)
  ensureCrictlPresent
  ensureCrioPresent
  EXTRA_PARAMS='--container-runtime=cri-o --network-plugin=cni'
  ;;
containerd)
  ensureCrictlPresent
  EXTRA_PARAMS='--container-runtime=containerd --network-plugin=cni'
  ;;
docker)
  ensureDockerCGroupSystemD
  ensureCriDockerdPresent
  EXTRA_PARAMS='--network-plugin=cni'
  ;;
*)
  usage
  exit 1
  ;;
esac

if ! minikube status &>/dev/null; then
  #TODO remove when https://github.com/kubernetes/minikube/issues/6391 is fixed
  [ "$(sudo sysctl -en fs.protected_regular)" != '0' ] &&
    sudo sysctl fs.protected_regular=0 && echo "Disabled fs.protected_regular to allow running Minikube in none mode"

  export MINIKUBE_WANTUPDATENOTIFICATION=false
  export MINIKUBE_WANTREPORTERRORPROMPT=false
  export MINIKUBE_HOME=$HOME
  export CHANGE_MINIKUBE_NONE_USER=true
  export KUBECONFIG=$HOME/.kube/config

  sudo mkdir -p /etc/kubernetes
  sudo chmod a+rwx /etc/kubernetes

  set -x
  # Default admission plugins do not need to be specified in apiserver.enable-admission-plugins:
  # https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#which-plugins-are-enabled-by-default
  #
  # With docker as continer runtime --extra-config=kubelet.cgroup-driver=systemd \
  # Added --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf due to  https://coredns.io/plugins/loop/
  # because under Ubuntu systemd-resolved service conflicts create a loop between CodeDNS and systemc DNS wrapper systemd-resolved.
  # TODO replace usage of /run/systemd/resolve/resolv.conf with some temporary file withot any 127.0.0.x entries ,because CRC add dnsmasq
  # shellcheck disable=SC2086
  sudo -E minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost \
    --kubernetes-version="${K8S_VERSION}" \
    --extra-config=apiserver.enable-admission-plugins="${ADMISSION_PLUGINS}" \
    --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf \
    --extra-config=kubelet.cgroup-driver=systemd \
    --addons=volumesnapshots \
    ${EXTRA_PARAMS}
  set +x
  sudo chmod -R a+rwx /etc/kubernetes &&
    minikube update-context &>/dev/null &&
    { minikube tunnel -c &>/tmp/minikube-tunnel.log & } &&
    echo "Minikube has been started"

  [ "$(sudo systemctl is-enabled kubelet)" == 'enabled' ] &&
    sudo systemctl disable kubelet && echo "Disabled Minikube from auto startup on boot"

  # install Cilium daemon set for CRIO or CNI mode
  # do no use --cni=cilium as it breaks network connectivity
  # it is more robust to setup network-plugin to cni and install CNI driver itself
  if [[ "${EXTRA_PARAMS}" == *'network-plugin'* ]]; then
    # Set cilium/cilium helm config: operator.numReplicas=1
    # because there is antiAffinity rule so that minikube cannot run 2 instances on single node
    # Set cilium/cilium helm config: cni.exclusive=false
    # because there is conflict with Istio https://github.com/istio/istio/issues/46764
    # making Istio CNI unable to spin istio-cni-node
    # shellcheck disable=SC2046
    helm install cilium cilium/cilium --namespace kube-system --set operator.replicas=1 --set cni.exclusive=false
  fi

  for ADDON in ${ADDONS}; do
    if [ "${ADDON}" == 'istio' ]; then
      ensureIstioctlIsPresent
      istioctl operator init
      minikube addons enable istio
    elif [ "${ADDON}" == 'nginx' ]; then
      addNginxIngress
    elif [ "${ADDON}" == 'dashboard' ]; then
      minikube addons enable dashboard
      addDashboardIngress
    elif [ "${ADDON}" != 'gatekeeper' ]; then # skip gatekeeper as it has to be installed as the last one
      minikube addons enable "${ADDON}"
    fi
  done

  [[ "${ADDONS}" == *gatekeeper* ]] && {
    installGatekeeper
  }
  echo "Minikube addons are started"
else
  echo "Minikube already started"
fi
