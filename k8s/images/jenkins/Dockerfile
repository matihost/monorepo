FROM jenkins/jenkins:2.332.3
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1046.v0ca_37783ecc5 \
  kubernetes:3580.v78271e5631dc \
  workflow-job:1180.v04c4e75dce43 \
  workflow-aggregator:578.vf9a_f99755f4a_ \
  cloudbees-disk-usage-simple:0.10 \
  credentials:1087.1089.v2f1b_9a_b_040e4 \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.19 \
  docker-workflow:1.28 \
  git:4.11.1 \
  configuration-as-code:1429.v09b_044a_c93de \
  timestamper:1.17 \
  github-branch-source:1628.vb_2f51293cb_78 \
  github-oauth:0.38 \
  ldap:2.8 \
  google-login:1.6 \
  matrix-auth:3.1 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:1.5 \
  command-launcher:81.v9c2cb_cb_db_392 \
  windows-slaves:1.8
