#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || { echo "Only Ubuntu supported";exit 1; }

MINIKUBE_VERSION=1.6.2
MINIKUBE_DIR_VERSION=1.6.2
CRICTL_VERSION=v1.17.0
CRIO_VERSION=1.16

function ensureMinikubePresent() {
  [ ! -x /usr/bin/minikube ] && curl -LO https://github.com/kubernetes/minikube/releases/download/v${MINIKUBE_DIR_VERSION}/minikube_${MINIKUBE_VERSION}.deb \
  && sudo dpkg -i minikube_${MINIKUBE_VERSION}.deb && rm -f minikube_${MINIKUBE_VERSION}.deb
}

function ensureDockerCGroupSystemD(){
  CGROUP_DRIVER=`docker info -f {{.CgroupDriver}} 2>/dev/null || echo 'Docker not running?'`
  [ "${CGROUP_DRIVER}" = "systemd" ] || { echo -e "Docker invalid status: ${CGROUP_DRIVER}.\nDocker has to be running and its cgroup-driver has to be systemd. Add "exec-opts": ["native.cgroupdriver=systemd"] to /etc/docker/daemon.json and restart docker service"; exit 1; }
}

function ensureCrioAndCrictlPresent(){
  [ -x /usr/local/bin/crictl ] || (\
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

  #TODO remove when fixed https://github.com/cri-o/cri-o/issues/1767
  [ -e /usr/bin/runc ] || sudo ln -s /usr/sbin/runc /usr/bin/runc
}

ensureMinikubePresent

case "$1" in
   --with-crio|crio|c) 
   ensureCrioAndCrictlPresent
   EXTRA_PARAMS='--container-runtime=cri-o'
   MODE='crio'
   ;; 
   --with-docker|docker|d|*) 
   ensureDockerCGroupSystemD
   EXTRA_PARAMS='--extra-config=kubelet.cgroup-driver=systemd'
   MODE='docker'
   ;; 
esac

minikube status &>/dev/null
if [ $? -ne 0  ]; then
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
    ${EXTRA_PARAMS}

  sudo chmod -R a+rwx /etc/kubernetes && \
  minikube update-context &>/dev/null && \
  minikube addons enable registry && \
  { minikube tunnel &>/tmp/minikube-tunnel.log & } && \
  echo "Minikube has been started"
else
  echo "Minikube already started"
fi







