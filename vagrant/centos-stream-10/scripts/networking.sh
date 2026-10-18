#!/usr/bin/env bash

# change hostname to centos
hostnamectl set-hostname centos

# add additional locally resolvable hostname
echo "172.30.250.4 magic.centos magic super.centos super" >>/etc/hosts

# configure the third network adapter (VBox adapter 3, see Vagrantfile) as it is set manual via VBox networking
# interface names are predictable (enp0s3, enp0s8, enp0s9), not eth2: adapter N is enp0s(N+5) for N>=2, so find it dynamically:
# it is the ethernet device which is not the default route one and has no IPv4 address assigned by DHCP
DEFAULT_DEV="$(ip route show default | awk '{print $5; exit}')"
STATIC_DEV=""
for dev in $(nmcli -t -f DEVICE,TYPE dev | awk -F: '$2=="ethernet" {print $1}'); do
  [ "${dev}" != "${DEFAULT_DEV}" ] || continue
  # VBox adapter 2 is DHCP host-only (has IPv4 address), adapter 3 is the static one (no address yet)
  if [ -z "$(ip -4 -o addr show dev "${dev}")" ]; then
    STATIC_DEV="${dev}"
    break
  fi
done
[ -n "${STATIC_DEV}" ] || {
  echo "ERROR: cannot find the network interface for 172.30.250.4" >&2
  exit 1
}
echo "=== Configuring ${STATIC_DEV} as 172.30.250.4"
# remove the auto created profile of the device (Wired connection N), if any
nmcli -g NAME,DEVICE con show | awk -F: -v d="${STATIC_DEV}" '$2==d {print $1}' | while read -r c; do nmcli con delete "$c"; done
nmcli c add con-name eth2 ifname "${STATIC_DEV}" type ethernet ipv4.method manual ipv4.addresses 172.30.250.4/24 ipv4.dns 10.0.2.3 connection.autoconnect yes ipv6.addr-gen-mode eui64
# add additional ip to the connection
nmcli c mod eth2 +ipv4.addresses 172.31.250.4/24
nmcli c u eth2

# use Firewalld as firewall manager
yum -y install firewalld

# iptables.service does not exist starting CentOS 10 (no iptables-services), firewalld uses nftables
# clean any leftovers from iptables, if present
if command -v iptables >/dev/null 2>&1; then
  iptables -t nat -F
  iptables -t mangle -F
  iptables -F
  iptables -X
fi

# enable firewalld for firewall management instead of iptables
systemctl enable firewalld --now

# install nc
yum -y install nmap-ncat

# the centos/stream10 box ships the vagrant user with a locked password (shadow entry "!"), so password login (used by
# scripts/host-ssh.sh to install the SSH key) is refused by sshd/PAM even when PasswordAuthentication is yes
echo 'vagrant:vagrant' | chpasswd
usermod -U vagrant

# ensure sshd can be used with password authen
# CentOS 10 sshd_config includes /etc/ssh/sshd_config.d/*.conf and the first value found wins, so use a drop-in
# which sorts before any other one (00-) instead of relying on sed against /etc/ssh/sshd_config
printf 'PasswordAuthentication yes\n' >/etc/ssh/sshd_config.d/00-vagrant-password-auth.conf
# neutralize the explicit "no" in the main file as well, if any
sed -i 's/^[[:space:]]*PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sshd -t || {
  echo "ERROR: invalid sshd configuration" >&2
  exit 1
}
sshd -T | grep -qi '^passwordauthentication yes$' || {
  echo "ERROR: sshd effective config still has PasswordAuthentication disabled" >&2
  exit 1
}
systemctl restart sshd
