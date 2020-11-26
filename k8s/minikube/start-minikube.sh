#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || {
  echo "Only Ubuntu supported"
  exit 1
}

function usage() {
  echo -e "Usage: $(basename "$0") [-h|--help|help] [--with-crio|crio|c] [--with-docker | docker | d] [--with-cni] [--with-istio | istio] [--with-gatekeeper | gatekeeper]

Starts Minikube in bare / none mode. Assumes latest Ubuntu.

Samples:
# start Minikube with docker minimum set of features (PSP, Nginx Ingress)
$(basename "$0") --with-docker

# start Minikube with docker maxmimum set of features (PSP, Nginx Ingress, NetworkPolicy via CNI/Cilium, Istio, Gatekeeper)
$(basename "$0") --with-docker --with-cni --with-gatekeeper --with-istio

# start with Crio as container engine (implies CNI aka enables NetworkPolicy)
$(basename "$0") --with-crio

# start with Crio as container engine with Istio
$(basename "$0") --with-crio --with-istio
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

function ensureCrioAndCrictlPresent() {
  CRIO_VERSION=1.19
  [ -x /usr/local/bin/crictl ] || (
    CRICTL_VERSION=$(git ls-remote -t https://github.com/kubernetes-sigs/cri-tools.git | cut -d'/' -f3 | sort -n | tail -n 1)
    wget "https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
    sudo tar zxvf "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz" -C /usr/local/bin
    rm -f "crictl-${CRICTL_VERSION}-linux-amd64.tar.gz"
  )

  [ -x /usr/bin/crio ] || (
    # shellcheck disable=SC1091
    . /etc/os-release

    sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list"
    wget -nv "https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key" -O Release.key
    sudo apt-key add Release.key
    rm -f Release.key

    sudo sh -c "echo 'deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${CRIO_VERSION}/x${NAME}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:crio:stable.list"
    wget -nv "https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/${CRIO_VERSION}/x${NAME}_${VERSION_ID}/Release.key" -O Release.key
    sudo apt-key add Release.key
    rm -f Release.key

    sudo apt-get update -qq
    sudo apt-get install -y cri-o cri-o-runc podman buildah
  )
  [ -x /opt/cni/bin/bridge ] || (
    sudo apt -y install containernetworking-plugins
  )

  # ensure runc and conmon binaries for CRIO are on sysmte path
  # related to https://github.com/cri-o/cri-o/issues/1767
  [ -e /usr/bin/runc ] || sudo ln -s /usr/sbin/runc /usr/bin/runc
  [ -e /usr/bin/conmon ] || sudo ln -s /usr/libexec/podman/conmon /usr/bin/conmon

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
  helm install gatekeeper gatekeeper/gatekeeper --namespace kube-system --set replicas=1
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
    # start Nginx ingress with PodSecurityPolicy: https://kubernetes.github.io/ingress-nginx/examples/psp/
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/docs/examples/psp/psp.yaml
    helm install -f ngnix.values.yaml ingress-nginx nginx-stable/nginx-ingress -n ingress-nginx
  }
}

ensureMinikubePresent
MODE=''
ADDONS="registry dashboard"
EXTRA_PARAMS=''

while [[ "$#" -gt 0 ]]; do
  case $1 in
  -h | --help | help)
    usage
    exit 1
    ;;
  --with-crio | crio | c)
    MODE='crio'
    ;;
  --with-docker | docker | d)
    MODE='docker'
    ;;
  --with-cni)
    EXTRA_PARAMS='--network-plugin=cni'
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
  ensureCrioAndCrictlPresent
  EXTRA_PARAMS='--container-runtime=cri-o --network-plugin=cilium'
  ;;
docker)
  ensureDockerCGroupSystemD
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

  # With docker as continer runtime --extra-config=kubelet.cgroup-driver=systemd \
  # Added --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf due to  https://coredns.io/plugins/loop/
  # because under Ubuntu systemd-resolved service conflicts create a loop between CodeDNS and systemc DNS wrapper systemd-resolved.
  # TODO replace usage of /run/systemd/resolve/resolv.conf with some temporary file withot any 127.0.0.x entries ,because CRC add dnsmasq
  # shellcheck disable=SC2086
  sudo -E minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost \
    --kubernetes-version='latest' \
    --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook,PodSecurityPolicy" \
    --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf \
    --extra-config=kubelet.cgroup-driver=systemd \
    --addons=pod-security-policy \
    ${EXTRA_PARAMS}

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
    # Set cilium/cilium help config: operator.numReplicas=1
    # because there is antiAffinity rule so that minikube cannot run 2 instances on single node
    # shellcheck disable=SC2046
    helm install cilium cilium/cilium --namespace kube-system --set operator.replicas=1 $([ "${MODE}" == 'crio' ] && echo '--set global.containerRuntime.integration=crio')
  fi

  for ADDON in ${ADDONS}; do
    if [ "${ADDON}" == 'istio' ]; then
      ensureIstioctlIsPresent
      istioctl operator init
      minikube addons enable istio
    elif [ "${ADDON}" != 'gatekeeper' ]; then # skip gatekeeper, as it needs to be installer last
      minikube addons enable "${ADDON}"
    fi
  done

  addNginxIngress

  # OPA Gatekeeper should be last as its installation make API timeouting for next calls for short period of time
  if [[ "${ADDONS}" == *'gatekeeper'* ]]; then
    installGatekeeper
  fi
else
  echo "Minikube already started"
fi
