FROM jenkins/jenkins:2.346.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.24 \
  kubernetes:3651.v908e7db_10d06 \
  workflow-job:1203.v7b_7023424efe \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:0.10 \
  credentials:1139.veb_9579fca_33b_ \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.19 \
  docker-workflow:1.29 \
  git:4.11.3 \
  configuration-as-code:1464.vd8507b_82e41a_ \
  timestamper:1.18 \
  github-branch-source:1656.v77eddb_b_e95df \
  github-oauth:0.39 \
  ldap:2.10 \
  google-login:1.6 \
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:1.5 \
  command-launcher:84.v4a_97f2027398 \
  windows-slaves:1.8.1
