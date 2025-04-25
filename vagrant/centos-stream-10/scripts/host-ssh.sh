#!/usr/bin/env bash
# Script runs from Vagrant host as the last step of VM boot
# It creates and copies SSH key to VM - in order to use normal SSH instead of vagrant ssh
[ -e ~/.ssh/id_rsa.vagrant.vm ] || ssh-keygen -b 4096 -N '' -t rsa -m PEM -f ~/.ssh/id_rsa.vagrant.vm
command -v sshpass >/dev/null || sudo apt -y install sshpass
ssh-keygen -f ~/.ssh/known_hosts -R "172.30.250.4"
sshpass -f <(echo "vagrant") ssh-copy-id -o PreferredAuthentications=password -i ~/.ssh/id_rsa.vagrant.vm.pub -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null vagrant@172.30.250.4
echo "Now you can also: \`ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.vagrant.vm vagrant@172.30.250.4\` to SSH to VM"
