#!/usr/bin/env bash
MINIKUBE_VERSION=1.6.2
[ ! -x /usr/bin/minikube ] && curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_${MINIKUBE_VERSION}.deb \
 && sudo dpkg -i minikube_${MINIKUBE_VERSION}.deb && rm -f minikube_${MINIKUBE_VERSION}.deb

if [[ "${OSTYPE}" =~ ^linux.*$ ]]; then
  CGROUP_DRIVER=`docker info -f {{.CgroupDriver}}`
  [ "${CGROUP_DRIVER}" = "systemd" ] || { echo 'Docker cgroup-driver has to be systemd. Add "exec-opts": ["native.cgroupdriver=systemd"] to /etc/docker/daemon.json and restart docker service'; exit 1; }
  minikube status &>/dev/null
  if [ ! $? -eq 0 ]; then
    export MINIKUBE_WANTUPDATENOTIFICATION=false
    export MINIKUBE_WANTREPORTERRORPROMPT=false
    export MINIKUBE_HOME=$HOME
    export CHANGE_MINIKUBE_NONE_USER=true
    export KUBECONFIG=$HOME/.kube/config

    sudo mkdir -p /etc/kubernetes
    sudo chmod a+rwx /etc/kubernetes

    # Added --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf due to  https://coredns.io/plugins/loop/
    # because under Ubuntu systemd-resolved service conflicts create a loop between CodeDNS and systemc DNS wrapper systemd-resolved.
    sudo -E minikube start --vm-driver=none --apiserver-ips 127.0.0.1 --apiserver-name localhost --extra-config=kubelet.cgroup-driver=systemd \
      --extra-config=apiserver.enable-admission-plugins="LimitRanger,NamespaceExists,NamespaceLifecycle,ResourceQuota,ServiceAccount,DefaultStorageClass,MutatingAdmissionWebhook" \
      --extra-config=kubelet.resolv-conf=/run/systemd/resolve/resolv.conf
    
    sudo chmod -R a+rwx /etc/kubernetes && \
    minikube update-context &>/dev/null && \
    minikube addons enable registry && \
    echo "Minikube has been started"
  else
    echo "Minikube already started"
  fi
else
  minikube start
fi