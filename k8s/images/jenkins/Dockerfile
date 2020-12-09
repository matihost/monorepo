FROM jenkins/jenkins:lts-jdk11
RUN jenkins-plugin-cli --plugins \
  kubernetes:1.28.3 \
  workflow-job:2.40 \
  workflow-aggregator:2.6 \
  credentials-binding:1.24 \
  git:4.5.0 \
  configuration-as-code:1.46 \
  timestamper:1.11.8 \
  github-branch-source:2.9.2 \
  matrix-auth:2.6.4 \
  prometheus:2.0.8 \
  simple-theme-plugin:0.6 \
  jdk-tool:1.4 \
  command-launcher:1.5 \
  jaxb:2.3.0.1
