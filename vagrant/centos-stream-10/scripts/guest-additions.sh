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

# Guest Additions must be built for the kernel that is going to run after the
# reboot, which is the newest installed one (the 'yum update' provisioner may
# have installed a newer kernel than the running one), not for 'uname -r'.
# Do not pin the Guest Additions to the host VirtualBox version: 7.2.6 does not
# compile against the current el10 kernels (hrtimer_init, vboxsf inode ops).
TARGET_KERNEL="$(rpm -q kernel-core --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' | sort -V | tail -n 1)"
echo "=== Running kernel: $(uname -r), kernel used after reboot: ${TARGET_KERNEL}"

yum -y install gcc "kernel-devel-${TARGET_KERNEL}" "kernel-headers" make bzip2 perl elfutils-libelf-devel tar
# Headers of the running kernel let the installer detect (via RHEL_DRM_VERSION in
# the kernel Makefile) that vboxvideo must not be built. Best effort only, the
# old package may be gone from the repositories.
RUNNING_KERNEL="$(uname -r)"
if [ "${RUNNING_KERNEL}" != "${TARGET_KERNEL}" ]; then
  yum -y install "kernel-devel-${RUNNING_KERNEL}" || echo "=== kernel-devel for ${RUNNING_KERNEL} not available, continuing"
fi

curl -sSL "https://download.virtualbox.org/virtualbox/${VBOX_VERSION}/VBoxGuestAdditions_${VBOX_VERSION}.iso" -o "/tmp/vboxadditions-${VBOX_VERSION}.iso"
WORK_DIR="$(mktemp -d)"
mount "/tmp/vboxadditions-${VBOX_VERSION}.iso" "${WORK_DIR}"
cd "${WORK_DIR}" || exit
# the installer may complain that headers for the running kernel are missing
# and that it cannot load the modules yet, this is fixed by the build and reboot below
sh ./VBoxLinuxAdditions.run --nox11 --target "$(mktemp -d)" || echo "=== VBoxLinuxAdditions.run returned $?, continuing with the module build"
/sbin/rcvboxadd quicksetup "${TARGET_KERNEL}"

# vboxvideo (the VirtualBox graphics driver) does not build on el10 kernels
# and is not needed: the VM uses the vmsvga controller (in-kernel vmwgfx).
# Its failure is not fatal, but vboxguest and vboxsf are mandatory.
echo "=== Verifying kernel modules built for ${TARGET_KERNEL}"
for module in vboxguest vboxsf; do
  if ! compgen -G "/lib/modules/${TARGET_KERNEL}/misc/${module}.ko*" >/dev/null; then
    echo "ERROR: ${module} kernel module was not built for ${TARGET_KERNEL}, see /var/log/vboxadd-setup.log" >&2
    exit 1
  fi
done
compgen -G "/lib/modules/${TARGET_KERNEL}/misc/vboxvideo.ko*" >/dev/null || echo "=== vboxvideo was not built, ignoring (not needed with vmsvga)"
