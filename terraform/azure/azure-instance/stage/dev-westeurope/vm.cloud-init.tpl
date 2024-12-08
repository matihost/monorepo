#cloud-config
# Azure place VM configuration in /var/lib/waagent/ovf-env.xml
# VM location of cloud-init configuration: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
---
repo_update: true
repo_upgrade: all

packages:
 - nginx
 - tinyproxy
 - plocate
 - dnsutils
 - azure-cli

# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 - systemctl enable --now nginx
 - echo -n "${ssh_pub}" |base64 -d > /home/${admin_username}/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/${admin_username}/.ssh/id_rsa
 - cat /home/${admin_username}/.ssh/id_rsa.pub >> /home/${admin_username}/.ssh/authorized_keys
 - 'chown ${admin_username}:${admin_username} /home/${admin_username}/.ssh/id_rsa*'
 - chmod 400 /home/${admin_username}/.ssh/id_rsa
 - sed -i -E "s/^#Allow 10.0.0.0\/8.*$/Allow 10.0.0.0\/8/" /etc/tinyproxy/tinyproxy.conf
 - systemctl restart tinyproxy
