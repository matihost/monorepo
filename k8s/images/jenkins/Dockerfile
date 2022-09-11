FROM jenkins/jenkins:2.361.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.24 \
  kubernetes:3704.va_08f0206b_95e \
  workflow-job:1232.v5a_4c994312f1 \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:170.va_fd5b_4ee6858 \
  credentials:1143.vb_e8b_b_ceee347 \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.21 \
  docker-workflow:521.v1a_a_dd2073b_2e \
  git:4.11.5 \
  configuration-as-code:1512.vb_79d418d5fc8 \
  timestamper:1.20 \
  github-branch-source:1694.vd46793a_c4a_57 \
  github-oauth:0.39 \
  ldap:2.12 \
  google-login:1.6 \
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:55.v1b_32b_6ca_f9ca \
  command-launcher:84.v4a_97f2027398 \
  windows-slaves:1.8.1
