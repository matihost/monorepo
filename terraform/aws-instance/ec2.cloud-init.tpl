#cloud-config
# EC2 location of cloud-init configuration: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
---
repo_update: true
repo_upgrade: all

packages:
 - nginx

# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 - systemctl enable --now nginx
 - echo -n "${ssh_pub}" |base64 -d > /home/ubuntu/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/ubuntu/.ssh/id_rsa
 - cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 - 'chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*'
 - chmod 400 /home/ubuntu/.ssh/id_rsa
