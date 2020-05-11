#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || { echo "Only Ubuntu supported";exit 1; }

CRIO_VERSION=1.17

function ensureMinikubePresent() {
  [ ! -x /usr/bin/minikube ] && \
  sudo apt -y install conntrack && \
  curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x minikube && sudo mv minikube /usr/bin/
}

function ensureDockerCGroupSystemD(){
  CGROUP_DRIVER=`docker info -f {{.CgroupDriver}} 2>/dev/null || echo 'Docker not running?'`
  [ "${CGROUP_DRIVER}" = "systemd" ] || { echo -e "Docker invalid status: ${CGROUP_DRIVER}.\nDocker has to be running and its cgroup-driver has to be systemd. Add "exec-opts": ["native.cgroupdriver=systemd"] to /etc/docker/daemon.json and restart docker service"; exit 1; }
}

function ensureCrioAndCrictlPresent(){
  [ -x /usr/local/bin/crictl ] || (\
  CRICTL_VERSION=`git ls-remote -t https://github.com/kubernetes-sigs/cri-tools.git | cut -d'/' -f3 |sort -n |tail -n 1`;\
  wget https://github.com/kubernetes-sigs/cri-tools/releases/download/${CRICTL_VERSION}/crictl-${CRICTL_VERSION}-linux-amd64.tar.gz ;\
  sudo tar zxvf crictl-${CRICTL_VERSION}-linux-amd64.tar.gz -C /usr/local/bin;\
  rm -f crictl-${CRICTL_VERSION}-linux-amd64.tar.gz)

  [ -x /usr/bin/crio ] || (\
    . /etc/os-release;\
    sudo sh -c "echo 'deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/x${NAME}_${VERSION_ID}/ /' > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list";\
    wget -nv https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable/x${NAME}_${VERSION_ID}/Release.key -O Release.key;\
    sudo apt-key add - < Release.key;\
    rm -f Release.key;\
    sudo apt-get update -qq;\
    sudo apt-get install -y cri-o-${CRIO_VERSION} podman buildah;\
  )
  [ -x /opt/cni/bin/bridge ] || (
    sudo apt -y install containernetworking-plugins
    sudo mkdir -p /opt/cni
    #TODO remove when kubelet will support cni-bin-dir flag for non-docer runtimes
    sudo ln -s /usr/lib/cni /opt/cni/bin
  )

  #TODO remove when fixed https://github.com/cri-o/cri-o/issues/1767
  [ -e /usr/bin/runc ] || sudo ln -s /usr/sbin/runc /usr/bin/runc
}

function ensureIstioctlIsPresent() {
  [ -x ~/.istioctl/bin/istioctl ] || (
    curl -sL https://istio.io/downloadIstioctl | sh -
    echo 'export PATH=$PATH:$HOME/.istioctl/bin' >> ~/.bashrc
    export PATH=$PATH:$HOME/.istioctl/bin
  )
}

ensureMinikubePresent
MODE='docker'
ADDONS="registry ingress dashboard"

case "$1" in
   --with-crio|crio|c) 
   MODE='crio'
   ;; 
   --with-docker|docker|d)
   MODE='docker'
   ;;
   --with-istio|istio)
   ADDONS="${ADDONS} istio"
   ;;
esac

case "${MODE}" in
  crio)
    ensureCrioAndCrictlPresent
    EXTRA_PARAMS='--container-runtime=cri-o --enable-default-cni --extra-config=kubelet.cni-bin-dir=/usr/lib/cni'
    ;;
  docker)
    ensureDockerCGroupSystemD
    EXTRA_PARAMS=''
esac


minikube status &>/dev/null
if [ $? -ne 0  ]; then
  #TODO remmove when https://github.com/kubernetes/minikube/issues/6391 is fixed
  [ "$(sudo sysctl -en fs.protected_regular)" != '0' ] \
  && sudo sysctl fs.protected_regular=0 && echo "Disabled fs.protected_regular to allow running Minikube in none mode"
  

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
  sudo -E minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost \
    --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook" \
    --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf \
    --extra-config=kubelet.cgroup-driver=systemd \
    ${EXTRA_PARAMS}

  sudo chmod -R a+rwx /etc/kubernetes && \
  minikube update-context &>/dev/null && \
  { minikube tunnel &>/tmp/minikube-tunnel.log & } && \
  echo "Minikube has been started"

  [ "$(sudo systemctl is-enabled kubelet)" == 'enabled' ] \
  && sudo systemctl disable kubelet && echo "Disabled Minikube from auto startup on boot"

  for ADDON in ${ADDONS}; do
    if [ "${ADDON}" == 'istio' ]; then
      ensureIstioctlIsPresent
      istioctl operator init
    fi
    minikube addons enable ${ADDON}
  done  
else
  echo "Minikube already started"
fi







