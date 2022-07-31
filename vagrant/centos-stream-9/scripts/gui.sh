#!/usr/bin/env bash

yum -y groupinstall workstation
systemctl set-default graphical
systemctl isolate graphical

cat <<EOF >/etc/gdm/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=vagrant
EOF
