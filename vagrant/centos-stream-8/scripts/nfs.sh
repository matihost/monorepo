#!/usr/bin/env bash

# start NFS server
yum -y install nfs-utils

# open on firewall
# mountd & rpc-bind are needed for showmount -e example.com to work
firewall-cmd --add-service={mountd,nfs,rpc-bind}
firewall-cmd --runtime-to-permanent

# enable NFS flags on SELinux level
setsebool -P nfs_export_all_rw on
setsebool -P httpd_use_nfs on
setsebool -P use_nfs_home_dirs on

systemctl enable nfs-server.service --now

# export sample directories
mkdir -p /mnt/storage/share{1..5}
touch /mnt/storage/share{1..5}/somefile{1..2}
chown -R nobody:nobody /mnt/storage/share{1..5}

echo '/mnt/storage/share5  *(rw,sync,root_squash)
/mnt/storage/share4  *(rw,sync,root_squash)
/mnt/storage/share3  *(rw,sync,root_squash)
/mnt/storage/share2  172.30.250.*(rw,sync,root_squash) 10.*(ro)' >>/etc/exports

# reload NFS exports
exportfs -rav

# Sample NFS client mounting via autofs
#
# mkdir -p /mnt/nas/vm
# echo '/mnt/nas/vm /etc/auto.vm-nfs' > /etc/auto.master.d/vm-nfs.autofs

# to mount only one NFS shared directory to /mnt/nas/vm/share3
# echo 'share3 -fstype=nfs,rw 172.30.250.3:/mnt/storage/share3' > /etc/auto.vm-nfs

# or wildcard mount of all exported subdirs of /mtn/storage to /mnt/nas/vm/*
# echo '* -fstype=nfs,rw 172.30.250.3:/mnt/storage/&' > /etc/auto.vm-nfs

# or direct mount
# mkdir -p /mnt/nas/vm
# echo '/- /etc/auto.vm-nfs' > /etc/auto.master.d/vm-nfs.autofs
# echo '/mnt/nas/vm/share3 -fstype=nfs,rw 172.30.250.3:/mnt/storage/share3' > /etc/auto.vm-nfs
