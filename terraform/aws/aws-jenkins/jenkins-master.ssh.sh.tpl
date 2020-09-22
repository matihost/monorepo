#!/usr/bin/env bash
[ -e /home/ubuntu/.ssh/id_rsa ] || {
 echo -n "${ssh_pub}" |base64 -d > /home/ubuntu/.ssh/id_rsa.pub
 echo -n "${ssh_key}" |base64 -d > /home/ubuntu/.ssh/id_rsa
 cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*
 chmod 400 /home/ubuntu/.ssh/id_rsa
}
