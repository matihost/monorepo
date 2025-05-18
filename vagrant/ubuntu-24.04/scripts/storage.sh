#!/usr/bin/env bash

# /dev/sdb - two normal partitions, /dev/sdb1 - swap, /dev/sdb2 - XFS
# /mnt/storage/swapfile - as additional swap as file
# /dev/sdc - assigned to LVM fully (future: make VDO storate and assign it to LVM)
# /dev/sdd - two partitions /dev/sdd{1..2} marked to use by LVM
# /dev/sd{e,f} - assigned to Stratis

# install Logical Volume Manager, XFS Dump/Restore Utility, Virtual Data Optimizer, AutoFS
apt -y install lvm2 xfsdump autofs

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
