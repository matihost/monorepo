#!/usr/bin/env bash
[ "$(lsb_release -is 2>/dev/null || echo "non-ubuntu")" = 'Ubuntu' ] || { echo "Only Ubuntu supported";exit 1; }

MINIKUBE_VERSION=1.6.2
CRICTL_VERSION=v1.17.0
CRIO_VERSION=1.15

function ensureMinikubePresent() {
  [ ! -x /usr/bin/minikube ] && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_${MINIKUBE_VERSION}.deb \
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


  #TODO replace disco with `lsb_release -cs` variable when https://github.com/containers/libpod/issues/4769 is fixed
  [ -x /usr/bin/crio ] || (\
    sudo add-apt-repository -y 'deb http://ppa.launchpad.net/projectatomic/ppa/ubuntu disco main';\
    sudo apt-get install -y cri-o-${CRIO_VERSION} podman buildah
  )

  #TODO remove when fixed https://github.com/cri-o/cri-o/issues/1767
  [ -e /usr/bin/runc ] || sudo ln -s /usr/sbin/runc /usr/bin/runc
}

function  ensureLocalMasqueradeRuleIsMissing(){
  COUNTER=1
  RC=1
  while [ "$[COUNTER++]" -le 60 ] && [ ${RC} -ne 0 ]; do
    sleep 1
    sudo iptables -t nat -D POSTROUTING -s 127.0.0.0/8 -o lo -m comment --comment "SNAT for localhost access to hostports" -j MASQUERADE 2>/dev/null
    RC=$?
  done
  [ "${RC}" -eq 0 ] || echo "Wrong iptable rule was not found during last ${COUNTER} seconds" && echo "Wrong iptables rule was removed"
} 

ensureMinikubePresent

case "$1" in
   --with-crio|crio|c) 
   ensureCrioAndCrictlPresent
   EXTRA_PARAMS='--container-runtime=cri-o'
   MODE='crio'
   ;; 
   --with-docker|dockker|d|*) 
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
  sudo -E minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost \
    --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook" \
    --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf \
    ${EXTRA_PARAMS}

  # To avoid https://github.com/kubernetes/kubernetes/issues/66067 
  #TODO run it in background as it happens upon some static pod creation
  [ "${MODE}" = "crio" ] && echo "Ensure breaking iptables rule is missing..." && ensureLocalMasqueradeRuleIsMissing
  sudo chmod -R a+rwx /etc/kubernetes && \
  minikube update-context &>/dev/null && \
  minikube addons enable registry && \
  { minikube tunnel &>/tmp/minikube-tunnel.log & } && \
  echo "Minikube has been started"
else
  echo "Minikube already started"
fi








