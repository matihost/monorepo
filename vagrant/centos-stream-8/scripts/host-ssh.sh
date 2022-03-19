#!/usr/bin/env bash
# Script runs from Vagrant host as the last step of VM boot
# It creates and copies SSH key to VM - in order to use normal SSH instead of vagrant ssh
[ -e ~/.ssh/id_rsa.vagrant.vm ] || ssh-keygen -b 4096 -N '' -t rsa -m PEM -f ~/.ssh/id_rsa.vagrant.vm
command -v sshpass >/dev/null || sudo apt -y install sshpass
sshpass -f <(echo "vagrant") ssh-copy-id -o PreferredAuthentications=password -i ~/.ssh/id_rsa.vagrant.vm.pub vagrant@172.30.250.3
echo "Now you can also: \`ssh vagrant@172.30.250.3\` to SSH to VM"
