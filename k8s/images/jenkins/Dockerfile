FROM jenkins/jenkins:2.277.1-lts-jdk11
RUN jenkins-plugin-cli --plugins \
  kubernetes:1.29.2 \
  workflow-job:2.40 \
  workflow-aggregator:2.6 \
  credentials-binding:1.24 \
  git:4.7.0 \
  configuration-as-code:1.47 \
  timestamper:1.12 \
  github-branch-source:2.10.2 \
  matrix-auth:2.6.6 \
  prometheus:2.0.8 \
  simple-theme-plugin:0.6 \
  jdk-tool:1.5 \
  command-launcher:1.5 \
  jaxb:2.3.0.1
