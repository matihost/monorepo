ARG JAVA_VERSION=21
FROM alpine as certs
RUN apk --update add ca-certificates
FROM gcr.io/kaniko-project/executor:debug as kaniko
FROM maven:3-amazoncorretto-$JAVA_VERSION-debian
RUN apt -y update && apt -y install binutils curl wget lsb-release gnupg apt-transport-https ca-certificates \
  && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - \
  && echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
  && wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor > /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list \
  && apt -y update && apt -y install terraform google-cloud-cli kubectl google-cloud-cli-kubectl-oidc google-cloud-cli-gke-gcloud-auth-plugin \
  && rm -rf /var/lib/apt/lists/*
COPY --from=kaniko /kaniko /kaniko
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV PATH="/kaniko:${PATH}"
ENV DOCKER_CONFIG=/kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json
