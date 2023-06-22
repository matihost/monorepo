ARG JAVA_VERSION=17
FROM alpine as certs
RUN apk --update add ca-certificates
FROM gcr.io/kaniko-project/executor:debug as kaniko
FROM maven:3-openjdk-${JAVA_VERSION}
RUN echo -e "[google-cloud-cli]\nname=Google Cloud CLI\nbaseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el8-x86_64\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=0\ngpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" > /etc/yum.repos.d/google-cloud-sdk.repo \
  && microdnf install google-cloud-cli kubectl google-cloud-cli-kubectl-oidc google-cloud-cli-gke-gcloud-auth-plugin \
  && microdnf clean all && rm -rf /var/cache/yum
COPY --from=kaniko /kaniko /kaniko
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV PATH="/kaniko:${PATH}"
ENV DOCKER_CONFIG=/kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json
