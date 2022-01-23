#!/bin/env bash

function install_software() {
  apt-get update -y
  apt-get install -y bash-completion vim less bind9-dnsutils iputils-ping ncat
  # install OpsAgent (it reserves 8888 and 2020 ports)
  curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
  bash add-google-cloud-ops-agent-repo.sh --also-install
}

function forward_to_apigee_runtime() {
  apt-get update -y
  apt-get install -y firewalld

  endpoint=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/attributes/apigee_runtime_endpoint -H "Metadata-Flavor: Google")

  sysctl -w net.ipv4.ip_forward=1
  sysctl -ew net.netfilter.nf_conntrack_buckets=1048576
  sysctl -ew net.netfilter.nf_conntrack_max=8388608
  echo 'net.ipv4.ip_forward=1
net.netfilter.nf_conntrack_buckets=1048576
net.netfilter.nf_conntrack_max=8388608
' >/etc/sysctl.d/99-mig-forward.conf

  if [ -x /bin/firewall-cmd ]; then
    firewall-cmd --add-masquerade
    firewall-cmd --add-forward-port=port=443:proto=tcp:toaddr="${endpoint}"
    firewall-cmd --runtime-to-permanent
  else
    iptables -t nat -A POSTROUTING -j MASQUERADE
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to-destination "${endpoint}"
  fi
}

# Main
systemctl is-enabled google-cloud-ops-agent.service &>/dev/null || {
  install_software
}
systemctl is-enabled firewalld.service &>/dev/null || {
  forward_to_apigee_runtime
}
