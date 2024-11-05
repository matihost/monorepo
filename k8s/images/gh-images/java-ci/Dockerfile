# syntax=docker/dockerfile:1
# check=skip=SecretsUsedInArgOrEnv
ARG JAVA_VERSION=21
FROM alpine AS certs
RUN apk --update add ca-certificates
FROM gcr.io/kaniko-project/executor:debug AS kaniko
FROM maven:3-eclipse-temurin-$JAVA_VERSION
RUN apt -y update && apt -y install binutils curl wget lsb-release gnupg apt-transport-https ca-certificates jq \
  && apt clean && apt autoclean && rm -rf /var/lib/apt/lists/*
COPY --from=kaniko /kaniko /kaniko
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV PATH="/kaniko:${PATH}"
ENV DOCKER_CONFIG=/kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json
