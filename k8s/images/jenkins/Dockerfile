FROM jenkins/jenkins:2.361.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.24 \
  kubernetes:3706.vdfb_d599579f3 \
  workflow-job:1239.v71b_b_a_124a_725 \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:170.va_fd5b_4ee6858 \
  credentials:1189.vf61b_a_5e2f62e \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.21 \
  docker-workflow:521.v1a_a_dd2073b_2e \
  git:4.12.1 \
  configuration-as-code:1512.vb_79d418d5fc8 \
  timestamper:1.20 \
  github-branch-source:1695.v88de84e9f6b_9 \
  github-oauth:0.39 \
  ldap:2.12 \
  google-login:1.6 \
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:55.v1b_32b_6ca_f9ca \
  command-launcher:90.v669d7ccb_7c31 \
  windows-slaves:1.8.1
