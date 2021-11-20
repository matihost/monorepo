#!/usr/bin/env bash
enable_gke_access() {
  disable_gke_access
  # Aliasing kubectl/helm commands to use local proxy
  alias kubectl="HTTPS_PROXY=localhost:8787 kubectl"
  alias kubectx="HTTPS_PROXY=localhost:8787 kubectx"
  alias kubens="HTTPS_PROXY=localhost:8787 kubens"
  alias k9s="HTTPS_PROXY=localhost:8787 k9s"
  alias ansible-playbook="HTTPS_PROXY=localhost:8787 ansible-playbook"
  alias helm="HTTPS_PROXY=localhost:8787 helm"
  echo "SSH to bastion vm: $(terraform output bastion_instance_name) and opening tunnel to proxy on bastion..." &&
    eval "$(terraform output bastion_tunnel_to_proxy | cut -d\" -f2)" &&
    echo "Get kubernetes credentials with internal ip for kube-apiserver in kubeconfig" &&
    eval "$(terraform output gke_connect_cmd | cut -d\" -f2)" &&
    echo "Commands kube[ctl|ns|ctx], k9s, ansible-playbook use tunnel in this shell to reach GKE API server" ||
    echo "Unable to connect to GKE..."
}

disable_gke_access() {
  unalias kubectl helm kubectx kubens k9s ansible-playbook 2>/dev/null
  prev_ssh_pid=$(pgrep -a ssh | grep shared-dev-bastion | cut -f1 -d' ')
  [ -n "${prev_ssh_pid}" ] && {
    echo "Killing previously setup tunnel..."
    kill "${prev_ssh_pid}"
  }
}

enable_gke_access
