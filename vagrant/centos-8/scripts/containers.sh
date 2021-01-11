#!/usr/bin/env bash

yum -y module install container-tools

#  configure rootless containers
# increas user namespaces
echo "user.max_user_namespaces=28633" >/etc/sysctl.d/userns.conf
sysctl -p /etc/sysctl.d/userns.conf

# allow exposing svc on port 80 (list all below port 1024)
echo "net.ipv4.ip_unprivileged_port_start=0" >/etc/sysctl.d/unprivport.conf
sysctl -p /etc/sysctl.d/unprivport.conf
