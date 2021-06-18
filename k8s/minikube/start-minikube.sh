#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || {
  echo "Only Ubuntu supported"
  exit 1
}

function usage() {
  echo -e "Usage: $(basename "$0") [-h|--help|help] [--with-containder|containerd|c] [--with-crio|crio] [--with-docker | docker | d] [--with-cni] [--with-version stable/latest/x.x.x] [--with-istio | istio] [--with-gatekeeper | gatekeeper] [--with-psp | psp]

Starts Minikube in bare / none mode. Assumes latest Ubuntu.

Mandatory option:
- Container runtime selection (--with-containerd, --with-crio, --with-docker (deprecated since k8s 1.20))

Minimum set of features enabled in every Minikube:
- Minikube Tunnel Loadbalancer along with Nginx Ingress
- Registry, Dashboard
- NetworkPolicy via CNI/Cilium (--with-cni - for docker container engine it has to be explicitely defined)

Optional features:
- K8S Version (--with-version) - default to stable, possible values: stable, latest, same as Minikube's --kubernetes-version
- Istio (--with-istio) - install base Istio w/o meaningful config, go to k8s/istio dir to install istio fully
- OPA Gatekeeper (--with-gatekeeper) - install base Gatekeeper w/o meaningful config, go to k8s/gatekeeper dir to install OPA Gatekeeper fully
- Enable PodSecurityPolicies (deprecated since k8s 1.21) (--with-psp | psp)

Samples:
# start Minikube with containerd minimum set of features
$(basename "$0") --with-containerd

# start Minikube with containerd with K8S latest version (default: stable)
$(basename "$0") --with-containerd --with-version latest


# start with Crio as container engine (implies CNI aka enables NetworkPolicy)
$(basename "$0") --with-crio

# deprecated: start Minikube with docker (CNI enablement has to be defined explicitely)
$(basename "$0") --with-docker --with-cni


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
}
function ensureCrioPresent() {
  CRIO_VERSION=1.21

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
    [[ "${ADMISSION_PLUGINS}" == *PodSecurityPolicy* ]] && {
      # start Nginx ingress with PodSecurityPolicy: https://kubernetes.github.io/ingress-nginx/examples/psp/
      kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/docs/examples/psp/psp.yaml
    }
    helm upgrade --install -f ngnix.values.yaml ingress-nginx nginx-stable/nginx-ingress -n ingress-nginx --create-namespace || {
      echo "Unable to install NGNIX, ngnix / k8s incompatibility? check NGinx Helm"
      exit 1
    }
  }
}

ensureMinikubePresent
K8S_VERSION='stable'
MODE=''

# TODO csi-hostpath-driver faild with containerd
# - VolumeSnaphots via csi-hostpath-driver.
# The csi-hostpath-driver addon sets up a dedicated storage class called csi-hostpath-sc
# that needs to be referenced in PVCs. The driver itself is created under the name:
# hostpath.csi.k8s.io - to be used for e.g. snapshot class definitions.
# ADDONS="registry dashboard volumesnapshots csi-hostpath-driver"
ADDONS="registry dashboard"
EXTRA_PARAMS=''
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
  --with-cni)
    EXTRA_PARAMS='--network-plugin=cni'
    ;;
  --with-istio | istio)
    ADDONS="${ADDONS} istio"
    ;;
  --with-gatekeeper | gatekeeper)
    ADDONS="${ADDONS} gatekeeper"
    ;;
  --with-psp | psp)
    export ADMISSION_PLUGINS="${ADMISSION_PLUGINS},PodSecurityPolicy"
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
  EXTRA_PARAMS='--container-runtime=cri-o --network-plugin=cilium'
  ;;
containerd)
  ensureCrictlPresent
  EXTRA_PARAMS='--container-runtime=containerd --network-plugin=cilium'
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
    helm install cilium cilium/cilium --namespace kube-system --set operator.replicas=1 $([ "${MODE}" == 'crio' ] && echo '--set global.containerRuntime.integration=crio') $([ "${MODE}" == 'containerd' ] && echo '--set global.containerRuntime.integration=containerd')
  fi

  for ADDON in ${ADDONS}; do
    if [ "${ADDON}" == 'istio' ]; then
      ensureIstioctlIsPresent
      istioctl operator init
      minikube addons enable istio
    elif [ "${ADDON}" != 'gatekeeper' ]; then # skip gatekeeper as it has to be installed as the last one
      minikube addons enable "${ADDON}"
    fi
  done

  addNginxIngress

  [[ "${ADDONS}" == *gatekeeper* ]] && {
    installGatekeeper
  }
  echo "Minikube addons are started"
else
  echo "Minikube already started"
fi
