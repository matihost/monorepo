FROM gcr.io/kaniko-project/executor:debug as kaniko
FROM ubuntu:22.04
COPY --from=kaniko /kaniko /kaniko
ENV PATH="/kaniko:${PATH}"
ENV DOCKER_CONFIG=/kaniko/.docker/
ENV DOCKER_CREDENTIAL_GCR_CONFIG=/kaniko/.config/gcloud/docker_credential_gcr_config.json
