#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
# dpkg conffile prompts are disabled by /etc/apt/apt.conf.d/99vagrant-noninteractive (see system.sh)
apt -y install ubuntu-desktop-minimal
systemctl set-default graphical.target

# VBox Guest Additions (clipboard, resize, drag and drop) come with the box, do not install Ubuntu virtualbox-guest-* (see guest-additions.sh)

mkdir -p /etc/gdm3
cat <<EOF2 >/etc/gdm3/custom.conf
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=vagrant
EOF2
