#!/usr/bin/env bash

# change hostname to ubuntu
hostnamectl set-hostname ubuntu

# add additional locally resolvable hostname
echo "172.30.250.5 magic.ubuntu magic super.ubuntu super" >>/etc/hosts

# install nmcli
apt -y install network-manager
systemctl enable --now NetworkManager.service

# ensure eth2 device is managed
nmcli d set eth2 managed yes

# configure eth2 as it is set manual via VBox networking
nmcli c add con-name eth2 ifname eth2 type ethernet ipv4.method manual ipv4.addresses 172.30.250.5/24 ipv4.dns 10.0.2.3 connection.autoconnect yes ipv6.addr-gen-mode eui64
# add additional ip to eth2 connection
nmcli c mod eth2 +ipv4.addresses 172.31.250.4/24
nmcli c u eth2

systemctl restart NetworkManager.service

# use Firewalld as firewall manager
apt -y install firewalld

# disable iptables
systemctl disable iptables --now

# clean any leftovers from iptables
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X

# enable firewalld for firewall management instead of iptables
systemctl enable firewalld --now

# install nc
apt -y install netcat-openbsd

# ensure sshd can be used with password authen is still valid
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/g' /etc/ssh/sshd_config

systemctl restart ssh
