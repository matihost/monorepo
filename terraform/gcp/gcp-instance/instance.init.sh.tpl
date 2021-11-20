#!/usr/bin/env bash
sudo apt update
sudo apt -y install bash-completion vim bind9-dnsutils

# install OpsAgent (it reserves 8888 and 2020 ports)
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install

# Apache2 sample showing region from instance metadata
apt-get install -y apache2 php
cd /var/www/html
rm -f index.{html,php} -f
META_REGION_STRING=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/zone" -H "Metadata-Flavor: Google")
REGION=`echo "$${META_REGION_STRING}" | awk -F/ '{print $4}'`
echo "Run in: $${REGION}" | tee index.html
