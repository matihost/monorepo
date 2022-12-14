FROM jenkins/jenkins:2.375.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1051.v9985666b_f6cc \
  pipeline-stage-view:2.28 \
  kubernetes:3743.v1fa_4c724c3b_7 \
  workflow-job:1254.v3f64639b_11dd \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:178.v1a_4d2f6359a_8 \
  credentials:1214.v1de940103927 \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.21 \
  docker-workflow:563.vd5d2e5c4007f \
  git:4.14.3 \
  configuration-as-code:1569.vb_72405b_80249 \
  timestamper:1.21 \
  github-branch-source:1696.v3a_7603564d04 \
  github-oauth:0.39 \
  ldap:2.12 \
  google-login:1.7 \
  matrix-auth:3.1.6 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:136.v23a_15f86c53d \
  jdk-tool:63.v62d2fd4b_4793 \
  command-launcher:90.v669d7ccb_7c31 \
  windows-slaves:1.8.1
