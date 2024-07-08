#!/usr/bin/env bash
apt -y update
apt -y install bash-completion vim bind9-dnsutils less plocate iputils-ping ncat firewalld

sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/30-nat-forward.conf

# shellcheck disable=SC2034
TOKEN="$(curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")"
# shellcheck disable=SC2034
external_interface_ip="$(curl -H "X-aws-ec2-metadata-token: $${TOKEN}" -v http://169.254.169.254/latest/meta-data/local-ipv4 2>/dev/null)"

# shellcheck disable=SC2154
firewall-cmd --zone=trusted --add-source="${private_cidr}"
firewall-cmd --direct --add-rule ipv4 nat POSTROUTING 0 -s "${private_cidr}" ! -d "${private_cidr}" -j SNAT --to "$${external_interface_ip}"
firewall-cmd --runtime-to-permanent
