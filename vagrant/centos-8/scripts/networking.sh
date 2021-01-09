#!/usr/bin/env bash

# change hostname to centos
hostnamectl set-hostname centos

# add additional locally resolvable hostname
echo "magic.centos   172.30.250.3" >>/etc/hosts

# configure eth2 as it is set manual via VBox networking
nmcli c add con-name eth2 ifname eth2 type ethernet ipv4.method manual ipv4.addresses 172.30.250.3/24 ipv4.dns 10.0.2.3 connection.autoconnect yes
nmcli c u eth2

# use Firewalld as firewall manager
yum -y install firewalld

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
yum -y install nmap-ncat
