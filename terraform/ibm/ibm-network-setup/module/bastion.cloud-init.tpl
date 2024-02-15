#cloud-config
# Cloud-init configuration location: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
#
# cloud init cli
# cloud-init status
---
repo_update: true
repo_upgrade: all

packages:
 - tinyproxy
 - postgresql-client
 - curl
 - wget

# Mezmo/LogDna configuration options
# https://github.com/logdna/logdna-agent-v2/blob/master/docs/README.md
# https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-ubuntu
write_files:
  - path: /etc/logdna.env
    content: |
      MZ_INGESTION_KEY=${log_ingestion_key}
      MZ_APIHOST=api.${region}.logging.cloud.ibm.com
      MZ_LOGHOST=logs.${region}.logging.cloud.ibm.com



# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 - echo -n "${ssh_pub}" |base64 -d > /home/ubuntu/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/ubuntu/.ssh/id_rsa
 - cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 - 'chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*'
 - chmod 400 /home/ubuntu/.ssh/id_rsa
 - echo "deb https://assets.logdna.com stable main" > /etc/apt/sources.list.d/logdna.list
 - wget -qO - https://assets.logdna.com/logdna.gpg | apt-key add -
 - apt-get update
 - apt-get -y install logdna-agent
 - systemctl enable --now logdna-agent
