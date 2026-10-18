#!/usr/bin/env bash

# change hostname to ubuntu
hostnamectl set-hostname ubuntu

# add additional locally resolvable hostname
echo "172.30.250.5 magic.ubuntu magic super.ubuntu super" >>/etc/hosts

# install nmcli
apt -y install network-manager
systemctl enable --now NetworkManager.service

# configure the third network adapter (VBox adapter 3, see Vagrantfile) as it is set manual via VBox networking
# interface names are predictable (enp0sN), not eth2: find it dynamically as the ethernet device
# which is not the default route one and has no IPv4 address assigned by DHCP
DEFAULT_DEV="$(ip route show default | awk '{print $5; exit}')"
STATIC_DEV=""
for dev in $(ip -o link show | awk -F': ' '$2 ~ /^(en|eth)/ {print $2}'); do
  [ "${dev}" != "${DEFAULT_DEV}" ] || continue
  if [ -z "$(ip -4 -o addr show dev "${dev}")" ]; then
    STATIC_DEV="${dev}"
    break
  fi
done
[ -n "${STATIC_DEV}" ] || {
  echo "ERROR: cannot find the network interface for 172.30.250.5" >&2
  exit 1
}
echo "=== Configuring ${STATIC_DEV} as 172.30.250.5"

# ensure the device is managed
nmcli d set "${STATIC_DEV}" managed yes

# configure it as it is set manual via VBox networking
nmcli c add con-name eth2 ifname "${STATIC_DEV}" type ethernet ipv4.method manual ipv4.addresses 172.30.250.5/24 ipv4.dns 10.0.2.3 connection.autoconnect yes ipv6.addr-gen-mode eui64
# add additional ip to eth2 connection
nmcli c mod eth2 +ipv4.addresses 172.31.250.4/24
nmcli c u eth2

# the box has a catch-all systemd-networkd rule (/run/systemd/network/zzzz-dracut-default.network) which runs DHCP on every link,
# so networkd waits forever for DHCP on this host-only link and systemd-networkd-wait-online times out (2 min) on each boot
# keep networkd away from it, NetworkManager owns it
printf '[Match]\nName=%s\n\n[Link]\nUnmanaged=yes\n' "${STATIC_DEV}" >/etc/systemd/network/00-eth2-unmanaged.network
networkctl reload

# the box ships two netplan files for its first NIC: 00-installer-config.yaml (enp0s3) and the stale 01-netcfg.yaml (eth0)
# the NIC is never called eth0, but netplan makes systemd-networkd-wait-online wait for it, which times out (2 min) on each boot
rm -f /etc/netplan/01-netcfg.yaml
netplan generate
systemctl daemon-reload

# use Firewalld as firewall manager
apt -y install firewalld

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
apt -y install netcat-openbsd

# ensure vagrant user can login with password (used by scripts/host-ssh.sh to install the SSH key)
echo 'vagrant:vagrant' | chpasswd
usermod -U vagrant

# ensure sshd can be used with password authen
# sshd_config includes /etc/ssh/sshd_config.d/*.conf and the first value found wins, so use a drop-in
# which sorts before any other one (00-)
mkdir -p /etc/ssh/sshd_config.d
printf 'PasswordAuthentication yes\n' >/etc/ssh/sshd_config.d/00-vagrant-password-auth.conf
sed -i 's/^[[:space:]]*PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sshd -t || {
  echo "ERROR: invalid sshd configuration" >&2
  exit 1
}
sshd -T | grep -qi '^passwordauthentication yes$' || {
  echo "ERROR: sshd effective config still has PasswordAuthentication disabled" >&2
  exit 1
}
systemctl restart ssh
