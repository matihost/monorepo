#cloud-config
# EC2 location of cloud-init configuration: /var/lib/cloud/instance/cloud-config.txt
# Cloud-init output logs: /var/log/cloud-init-output.log
---
repo_update: true
repo_upgrade: all

packages:
 - nginx
 - plocate

write_files:
  - path: /tmp/init.sh
    content: |
      # configure Nginx for Instana
      ln -sf /etc/nginx/sites-available/default-instana /etc/nginx/sites-enabled/default
      systemctl restart nginx
      # install Instana Agent
%{ if length(vars) > 0 && vars[0] != "" }
      INSTANA_TOKEN="${vars[0]}"
      INSTANA_ENDPOINT="${vars[1]}"
      curl -o setup_agent.sh https://setup.instana.io/agent \
        && chmod 700 ./setup_agent.sh \
        && sudo ./setup_agent.sh -a "$${INSTANA_TOKEN}" -d "$${INSTANA_TOKEN}" -t dynamic -e "$${INSTANA_ENDPOINT}" -s -y
%{ endif }
  - path: /etc/nginx/sites-available/default-instana
    content: |
      server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;

        index index.html index.htm index.nginx-debian.html;

        server_name _;

        location / {
          # First attempt to serve request as file, then
          # as directory, then fall back to displaying a 404.
          try_files $uri $uri/ =404;
        }

        # required by Instana Agent to grab Nginx Metrics
        location /nginx_status {
          stub_status  on;
          access_log   off;
        }
      }

# cloud-init creates a final script in: /var/lib/cloud/instance/scripts/runcmd
runcmd:
 - systemctl enable --now nginx
 - echo -n "${ssh_pub}" |base64 -d > /home/ubuntu/.ssh/id_rsa.pub
 - echo -n "${ssh_key}" |base64 -d > /home/ubuntu/.ssh/id_rsa
 - cat /home/ubuntu/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys
 - 'chown ubuntu:ubuntu /home/ubuntu/.ssh/id_rsa*'
 - chmod 400 /home/ubuntu/.ssh/id_rsa
 - chmod +x /tmp/init.sh
 - /tmp/init.sh
