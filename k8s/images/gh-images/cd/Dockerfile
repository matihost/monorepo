# syntax=docker/dockerfile:1
FROM ubuntu:24.04
RUN apt -y update && apt -y install make binutils curl wget lsb-release gnupg apt-transport-https ca-certificates jq \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
  && apt -y update && apt -y install google-cloud-cli kubectl google-cloud-cli-kubectl-oidc google-cloud-cli-gke-gcloud-auth-plugin
RUN curl -sL https://api.github.com/repos/opentofu/opentofu/releases/latest | jq -r ".assets[] | select(.name | test(\"amd64.deb\")) | .browser_download_url" | xargs curl -s -L -o "/tmp/tofu.deb" \
  && apt -y install /tmp/tofu.deb && rm -rf /tmp/tofu.deb  \
  && curl -sL https://api.github.com/repos/gruntwork-io/terragrunt/releases/latest | jq -r ".assets[] | select(.name | test(\"linux_amd64\")) | .browser_download_url" | xargs curl -s -L -o "/usr/local/bin/terragrunt" \
  && chmod a+x /usr/local/bin/terragrunt \
  && rm -rf /var/lib/apt/lists/*
