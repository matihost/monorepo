#!/usr/bin/env bash

# /dev/sdb - two normal partitions, /dev/sdb1 - swap, /dev/sdb2 - XFS
# /mnt/storage/swapfile - as additional swap as file
# /dev/sdc - assigned to LVM fully (future: make VDO storate and assign it to LVM)
# /dev/sdd - two partitions /dev/sdd{1..2} marked to use by LVM
# /dev/sd{e,f} - assigned to Stratis

# install Logical Volume Manager, XFS Dump/Restore Utility, Virtual Data Optimizer, AutoFS
yum -y install lvm2 xfsdump vdo autofs

# Enable autofs
systemctl enable autofs.service --now

# Static /dev/sdb partitioning (swap + xfs partitions)
parted /dev/sdb mklabel gpt
parted /dev/sdb mkpart swap1 linux-swap 2048s 1024MiB
parted /dev/sdb mkpart storage1 xfs 1025MiB 100%
udevadm settle

# swap partition
mkswap /dev/sdb1
echo '/dev/sdb1  swap  swap  defaults 0 0' >>/etc/fstab
systemctl daemon-reload
mount -a

# second partition as xfs
mkfs.xfs /dev/sdb2
mkdir -p /mnt/storage
echo '/dev/sdb2  /mnt/storage  xfs  defaults 0 0' >>/etc/fstab
systemctl daemon-reload
mount -a

# swap as file
dd if=/dev/zero of=/mnt/storage/swapfile bs=1M count=600
chmod 600 /mnt/storage/swapfile
mkswap /mnt/storage/swapfile
echo "/mnt/storage/swapfile swap swap defaults 0 0" >>/etc/fstab
systemctl daemon-reload
# to validate /etc/fstab
findmnt -x
mount -a

## LVM

# vdo fail to start on CentOS 8
# vdo storage could be part of lvm
# sudo vdo create --name=vdo1 --device=/dev/sdc  --vdoLogicalSize=50G

parted /dev/sdd mklabel gpt
parted /dev/sdd mkpart lvm1 2048s 2048MiB
parted /dev/sdd mkpart lvm2 2049MiB 100%
parted /dev/sdd set 1 lvm on
parted /dev/sdd set 2 lvm on
udevadm settle

pvcreate /dev/sdc /dev/sdd{1,2}
# create VG with PE being 16MiB
vgcreate vg01 /dev/sdc /dev/sdd{1,2} -s 16M
lvcreate -n lv01 -L 6GiB vg01
# or provide size wit number of PhysicalExtents (PE)
# lvcreate -n lv01 -l 384 vg01

mkfs.xfs /dev/vg01/lv01
mkdir -p /mnt/lv01
echo '/dev/vg01/lv01 /mnt/lv01  xfs  defaults 0 0' >>/etc/fstab
systemctl daemon-reload
mount -a

## Stratis

yum -y install stratis-cli stratisd autofs

# workaround for https://bugzilla.redhat.com/show_bug.cgi?id=1782856
# or https://github.com/stratis-storage/stratisd/issues/1751
# however it only solve the problem of starting stratisd service - it still does not work
# so any volume created by stratis cannot be mounted by /etc/fstab - so autofs is a choice here
mkdir -p /etc/systemd/system/stratisd.service.d
echo "[Unit]
Before=local-fs-pre.target
After=kmod-static-nodes.service systemd-tmpfiles-setup-dev.service
" >/etc/systemd/system/stratisd.service.d/override.conf

systemctl enable stratisd.service --now

# ensure magic numbers are removed from block devices for stratis to work
wipefs -a /dev/sde
wipefs -a /dev/sdf

# create stratis pool from /dev/sdd and sde block devices
stratis pool create pool1 /dev/{sde,sdf}

# create /stratis/pool1/sfs1 filesystem
# stratis is formated with XFS automatially
stratis filesystem create pool1 sfs1

# it would work if stratis start successfulyl upon reboot
# but autofs has to be used instead
mkdir -p /mnt/stratis
echo '#/dev/stratis/pool1/sfs1 /mnt/stratis/sfs1                       xfs     defaults,nofail,x-systemd.requires=stratisd.service        0 0' >>/etc/fstab

echo "/mnt/stratis /etc/auto.stratis" >/etc/auto.master.d/stratis.autofs
# fstype option is required when mounting local volumes
echo "sfs1 -fstype=xfs,rw :/dev/stratis/pool1/sfs1" >/etc/auto.stratis

systemctl reload autofs.service

# temporal directory managed and cleaned by systemd-tmpfiles timer
# items older than 30 seconds are removed
echo '#Type Path            Mode UID  GID  Age Argument
d     /run/volatile   0700 root root 30s -
' >/etc/tmpfiles.d/volatile.conf
systemd-tmpfiles --create
