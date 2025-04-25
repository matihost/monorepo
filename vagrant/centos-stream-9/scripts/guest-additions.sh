#!/usr/bin/env bash

VBOX_VERSION="$(curl -s https://download.virtualbox.org/virtualbox/LATEST.TXT)"
# disable SELinux to prevent https://www.virtualbox.org/ticket/19756
sed -i 's/SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config
# to disable SELinux for current run
setenforce Permissive

# just in case SELinux is still enabled
semanage fcontext -d "/opt/VBoxGuestAdditions-${VBOX_VERSION}/other/mount.vboxsf"
restorecon "/opt/VBoxGuestAdditions-${VBOX_VERSION}/other/mount.vboxsf"

# workaround for https://github.com/dotless-de/vagrant-vbguest/issues/405
echo 'vboxsf' >/etc/modules-load.d/vboxsf.conf
systemctl restart systemd-modules-load.service
echo '=== Verifying vboxsf module is loaded'
grep vbox /proc/modules

yum -y install gcc kernel-devel kernel-headers make bzip2 perl elfutils-libelf-devel

curl -sSL "https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso" -o "/tmp/vboxadditions-${VBOX_VERSION}.iso"
WORK_DIR="$(mktemp -d)"
mount "/tmp/vboxadditions-${VBOX_VERSION}.iso" "${WORK_DIR}"
cd "${WORK_DIR}" || exit
sh ./VBoxLinuxAdditions.run --nox11 --target "$(mktemp -d)"
/sbin/rcvboxadd quicksetup all
