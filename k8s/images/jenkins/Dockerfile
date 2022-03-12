FROM jenkins/jenkins:2.332.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.7.0 \
  kubernetes:3546.v6103d89542d6 \
  workflow-job:1174.vdcb_d054cf74a_ \
  workflow-aggregator:2.7 \
  cloudbees-disk-usage-simple:0.10 \
  credentials:1074.v60e6c29b_b_44b_ \
  credentials-binding:1.27.1 \
  docker-commons:1.19 \
  docker-workflow:1.28 \
  git:4.10.3 \
  configuration-as-code:1414.v878271fc496f \
  timestamper:1.17 \
  github-branch-source:1583.v18d333ef7379 \
  github-oauth:0.37 \
  ldap:2.8 \
  google-login:1.6 \
  matrix-auth:3.1 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:1.5 \
  command-launcher:1.6 \
  windows-slaves:1.8 \
  jaxb:2.3.0.1
