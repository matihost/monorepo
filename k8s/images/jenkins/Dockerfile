FROM jenkins/jenkins:2.361.3
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.27 \
  kubernetes:3734.v562b_b_a_627ea_c \
  workflow-job:1254.v3f64639b_11dd \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:178.v1a_4d2f6359a_8 \
  credentials:1189.vf61b_a_5e2f62e \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.21 \
  docker-workflow:528.v7c193a_0b_e67c \
  git:4.13.0 \
  configuration-as-code:1569.vb_72405b_80249 \
  timestamper:1.20 \
  github-branch-source:1696.v3a_7603564d04 \
  github-oauth:0.39 \
  ldap:2.12 \
  google-login:1.6 \
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:136.v23a_15f86c53d \
  jdk-tool:55.v1b_32b_6ca_f9ca \
  command-launcher:90.v669d7ccb_7c31 \
  windows-slaves:1.8.1
