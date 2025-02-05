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

      # install otel agent
      curl -sL https://api.github.com/repos/open-telemetry/opentelemetry-collector-releases/releases | \
        jq -r ".[0].assets[] | select(.name | (endswith(\"linux_$(dpkg --print-architecture).deb\")) and startswith(\"otelcol-contrib\")) | .browser_download_url" | \
        xargs curl -s -L -o "/tmp/otelcol-contrib.deb"
      apt -y install /tmp/otelcol-contrib.deb
      systemctl stop otelcol-contrib
      mv /etc/otelcol-contrib/config.yaml /etc/otelcol-contrib/config.yaml.orig
      ln -s /etc/otelcol-config-instana.yaml /etc/otelcol-contrib/config.yaml
      sed -i "s/INSTANA_HOSTNAME/$(hostname -A)/g" /etc/otelcol-config-instana.yaml
      # so that otelcol-contrib user which runs systemctl service can access journal logs
      usermod -a -G adm otelcol-contrib
      # install instana agent
      curl -o setup_agent.sh https://setup.instana.io/agent \
        && chmod 700 ./setup_agent.sh \
        && sudo ./setup_agent.sh -a "$${INSTANA_TOKEN}" -d "$${INSTANA_TOKEN}" -t dynamic -e "$${INSTANA_ENDPOINT}" -s -y
      # wait for Instana agent to start its OTEL ports
      sleep 30
      # start otel agent
      systemctl start otelcol-contrib
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
  - path: /etc/otelcol-config-instana.yaml
    content: |
      # See https://www.ibm.com/docs/en/instana-observability/288?topic=opentelemetry-collecting-linux-system-logs for details
      # Not working on Instana SAAS Trial
      # "error": "not retryable error: Permanent error: rpc error: code = PermissionDenied desc = None of the tenants are licensed to send log data: org-tenant"
      receivers:
        journald:
          directory: /var/log/journal

      exporters:
        otlp/instanaAgent:
          endpoint: "http://localhost:4317"
          tls:
            insecure: true
        otlp/instanaSaas:
          endpoint: "${vars[2]}"
          headers:
            x-instana-key: "${vars[0]}"
            x-instana-host: INSTANA_HOSTNAME

      processors:
        transform/journald:
          error_mode: ignore
          log_statements:
            - context: log
              statements:
                # https://github.com/open-telemetry/opentelemetry-collector-contrib/blob/main/pkg/ottl/ottlfuncs/README.md
                #--- severity level priority
                - set(severity_number, SEVERITY_NUMBER_DEBUG) where Int(body["PRIORITY"]) == 7
                - set(severity_number, SEVERITY_NUMBER_INFO) where Int(body["PRIORITY"]) == 6
                - set(severity_number, SEVERITY_NUMBER_INFO2) where Int(body["PRIORITY"]) == 5
                - set(severity_number, SEVERITY_NUMBER_WARN) where Int(body["PRIORITY"]) == 4
                - set(severity_number, SEVERITY_NUMBER_ERROR) where Int(body["PRIORITY"]) == 3
                - set(severity_number, SEVERITY_NUMBER_FATAL) where Int(body["PRIORITY"]) <= 2
                - set(attributes["priority"], body["PRIORITY"])
                #unneeded - set(attributes["level"], severity_number)
                #--- trace who and what generated log message
                - set(attributes["process.comm"], body["_COMM"])
                - set(attributes["process.exec"], body["_EXE"])
                - set(attributes["process.uid"], body["_UID"])
                - set(attributes["process.gid"], body["_GID"])
                - set(attributes["owner_uid"], body["_SYSTEMD_OWNER_UID"])
                - set(attributes["unit"], body["_SYSTEMD_UNIT"])
                - set(attributes["syslog_identifier"], body["SYSLOG_IDENTIFIER"])
                #--- verbose extras
                #- set(attributes["process.pid"], body["_PID"])
                #- set(attributes["process.cmdline"], body["_CMDLINE"])
                #- set(attributes["_SYSTEMD_SLICE"], body["_SYSTEMD_SLICE"])
                #- set(attributes["runtime_scope"], body["_RUNTIME_SCOPE"])
                #--- create low cardinality "job" identifier
                # user@xxx.service mnt-xxx.mount run-xxx.scope session-xxx.scope
                ## ^([a-zA-Z_]{3,20})   ([^\\-\\.\\@0-9]+).*
                - set(attributes["syslog_identifier_prefix"], ConvertCase(body["SYSLOG_IDENTIFIER"], "lower")) where body["SYSLOG_IDENTIFIER"] != nil
                - replace_pattern(attributes["syslog_identifier_prefix"], "^[^a-zA-Z]*([a-zA-Z]{3,25}).*", "$$1") where body["SYSLOG_IDENTIFIER"] != nil
                - set(attributes["unit_prefix"], ConvertCase(body["_SYSTEMD_UNIT"], "lower")) where body["_SYSTEMD_UNIT"] != nil
                - replace_pattern(attributes["unit_prefix"], "^[^a-zA-Z]*([a-zA-Z]{3,25}).*", "$$1") where body["_SYSTEMD_UNIT"] != nil
                - set(attributes["job"], attributes["syslog_identifier_prefix"])
                - set(attributes["job"], attributes["unit_prefix"]) where attributes["job"] == nil and attributes["unit_prefix"] != nil
                #- delete_key(attributes, "syslog_identifier_prefix")
                #- delete_key(attributes, "unit_prefix")
                #--- remove jorunald metadata and make log body simple
                - set(body, body["MESSAGE"])
        groupbyattrs:
          keys:
            - service.name
            - host.name
            - receiver
            - job
        batch:

      service:
        pipelines:
          logs:
            receivers: [journald]
            processors: [transform/journald, batch, groupbyattrs]
            # to route via Instana Agent
            exporters: [otlp/instanaAgent]
            # to route logs directly to Instana SAAS instance
            # exporters: [otlp/instanaSaas]




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
