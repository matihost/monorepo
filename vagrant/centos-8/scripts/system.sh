#!/usr/bin/env bash

# make journal persistent in /var/log/journal (instead in /run/log/journal)
sed -i -E 's/^#Storage=.*$/Storage=persistent/g' /etc/systemd/journald.conf
systemctl restart systemd-journald.service

# additional Grub2 entries for rescue, emergency, and rootpasswd entries
DEFAULT_KERNEL_PATH="$(grubby --default-kernel)"
DEFAULT_INITRDIMG_PATH="$(grubby --info="$(grubby --default-index)" | grep -E '^initrd=' | sed -E 's/initrd="(.*.img).*"$/\1/g')"

# rescue boot
cp "${DEFAULT_KERNEL_PATH}" /boot/vmlinuz-rescue
cp "${DEFAULT_INITRDIMG_PATH}" /boot/initramfs-rescue.img
grubby --add-kernel="/boot/vmlinuz-rescue" --title="rescue boot" --initrd="/boot/initramfs-rescue.img" --copy-default --args="systemd.unit=rescue.target"

# emergency boot
# emergency boot mounts / in ro mode
# to remount / in rw mode:
# mount -o rw,remount /
cp "${DEFAULT_KERNEL_PATH}" /boot/vmlinuz-emergency
cp "${DEFAULT_INITRDIMG_PATH}" /boot/initramfs-emergency.img
grubby --add-kernel="/boot/vmlinuz-emergency" --title="emergency boot" --initrd="/boot/initramfs-emergency.img" --copy-default --args="systemd.unit=emergency.target"

# rootpasswd boot
# it breaks before pivoting to /sysroot, allow to change root password
# root password change procedure:
#  mount -o rw,remount /sysroot
#  chroot /sysroot
#  passwd root
# to force SELinux to call restorecon -R / upon next boot to ensure correct fcontext for /etc/shadow
#  touch /.autorelabel
cp "${DEFAULT_KERNEL_PATH}" /boot/vmlinuz-rootpasswd
cp "${DEFAULT_INITRDIMG_PATH}" /boot/initramfs-rootpasswd.img
grubby --add-kernel="/boot/vmlinuz-rootpasswd" --title="rootpasswd boot" --initrd="/boot/initramfs-rootpasswd.img" --copy-default --args="rd.break"
