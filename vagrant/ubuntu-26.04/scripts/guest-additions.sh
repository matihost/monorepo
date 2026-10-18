#!/usr/bin/env bash

# The bento/ubuntu box already ships VirtualBox Guest Additions installed from the ISO in /opt/VBoxGuestAdditions-*
# (vboxadd, vboxadd-service, own vboxguest/vboxsf modules). Do NOT install Ubuntu virtualbox-guest-utils/-x11 on top:
# both run VBoxService, which allows a single instance, so vboxadd-service fails to start after reboot,
# and removing the Ubuntu package later deletes the /usr/sbin/VBoxService symlink of the box.

# ensure shared folders module is loaded on boot
echo 'vboxsf' >/etc/modules-load.d/vboxsf.conf
systemctl restart systemd-modules-load.service

echo '=== Verifying Guest Additions kernel modules and services'
grep -E 'vboxguest|vboxsf' /proc/modules || {
  echo "ERROR: vboxguest/vboxsf kernel modules are not loaded" >&2
  exit 1
}
systemctl is-enabled vboxadd.service vboxadd-service.service || {
  echo "ERROR: box Guest Additions services are missing" >&2
  exit 1
}
