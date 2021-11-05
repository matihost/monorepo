FROM jenkins/jenkins:2.303.3
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.7.0 \
  kubernetes:1.30.6 \
  workflow-job:2.42 \
  workflow-aggregator:2.6 \
  cloudbees-disk-usage-simple:0.10 \
  credentials:2.6.1 \
  credentials-binding:1.27 \
  docker-commons:1.17 \
  docker-workflow:1.26 \
  git:4.10.0 \
  configuration-as-code:1.54 \
  timestamper:1.13 \
  github-branch-source:2.11.3 \
  github-oauth:0.34 \
  ldap:2.7 \
  google-login:1.6 \
  matrix-auth:2.6.8 \
  authorize-project:1.4.0 \
  prometheus:2.0.10 \
  simple-theme-plugin:0.7 \
  jdk-tool:1.5 \
  command-launcher:1.6 \
  windows-slaves:1.8 \
  jaxb:2.3.0.1
