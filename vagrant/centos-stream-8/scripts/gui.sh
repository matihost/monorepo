#!/usr/bin/env bash

yum -y groupinstall workstation
systemctl set-default graphical
systemctl isolate graphical
yum -y install open-vm-tools open-vm-tools-desktop xorg-x11-drv-vmware

mkdir -p /etc/gdm
cat <<EOF >/etc/gdm/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=vagrant
EOF
