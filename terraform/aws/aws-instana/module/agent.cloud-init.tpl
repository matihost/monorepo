#cloud-config
# EC2 location of cloud-init configuration: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
---
repo_update: true
repo_upgrade: all

packages:
 - plocate

write_files:
  - path: /tmp/init.sh
    content: |
      # install Instana Agent
      INSTANA_TOKEN="${vars[0]}"
      INSTANA_ENDPOINT="${vars[1]}"
      curl -o setup_agent.sh https://setup.instana.io/agent \
        && chmod 700 ./setup_agent.sh \
        && sudo ./setup_agent.sh -y -a "$${INSTANA_TOKEN}" -m aws -t dynamic -e "$${INSTANA_ENDPOINT}" -s

# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 - echo -n "${ssh_pub}" |base64 -d > /home/ubuntu/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/ubuntu/.ssh/id_rsa
 - cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 - 'chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*'
 - chmod 400 /home/ubuntu/.ssh/id_rsa
 - chmod +x /tmp/init.sh
 - /tmp/init.sh
