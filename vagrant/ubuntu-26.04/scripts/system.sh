#!/usr/bin/env bash

# provisioning has no terminal: never prompt about config files modified locally or by the box (keep the current ones)
echo 'Dpkg::Options { "--force-confdef"; "--force-confold"; };' >/etc/apt/apt.conf.d/99vagrant-noninteractive

# change timezone
timedatectl set-timezone Europe/Warsaw

# make journal persistent in /var/log/journal (instead in /run/log/journal)
sed -i -E 's/^#Storage=.*$/Storage=persistent/g' /etc/systemd/journald.conf
systemctl restart systemd-journald.service

# increase wait time to 5 seconds
sed -i -E 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=5/g' /etc/default/grub
update-grub

# sample users
groupadd testers
groupadd infra
for i in {1..3}; do useradd -m -s /bin/bash -g testers "test${i}"; done

for i in {1..3}; do echo "test${i}:test" | chpasswd; done
for i in {1..3}; do useradd -m -s /bin/bash -g infra "infra${i}"; done
for i in {1..3}; do echo "infra${i}:test" | chpasswd; done

# sample colaborative directory
mkdir /src
chmod 775 /src
chown root:testers /src
# files, and directories will have owner same as /src directory which is testing
chmod g+s /src

# acl is not present by default starting Ubuntu 20.04
apt -y install acl
# allow full access to infra group as well
setfacl -m g:infra:rwx /src

# ensure new files and directories will get correct ACLs
setfacl -m d:u::rwx /src
setfacl -m d:u::rwx /src
setfacl -m d:g::rwx /src
setfacl -m d:o::r-x /src
setfacl -m d:g:infra:rwx /src

# Ubuntu uses AppArmor, install convenience tools
apt -y install apparmor-utils bash-completion vim man-db
