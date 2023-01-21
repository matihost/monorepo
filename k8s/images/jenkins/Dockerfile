FROM jenkins/jenkins:2.375.2
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1071.v1a_188a_562481 \
  pipeline-stage-view:2.29 \
  kubernetes:3834.vdc85747145e6 \
  workflow-job:1268.v6eb_e2ee1a_85a \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:178.v1a_4d2f6359a_8 \
  credentials:1214.v1de940103927 \
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.21 \
  docker-workflow:563.vd5d2e5c4007f \
  git:5.0.0 \
  configuration-as-code:1569.vb_72405b_80249 \
  timestamper:1.21 \
  github-branch-source:1701.v00cc8184df93 \
  github-oauth:0.39 \
  ldap:659.v8ca_b_a_fe79fa_d \
  google-login:1.7 \
  matrix-auth:3.1.6 \
  authorize-project:1.4.0 \
  prometheus:2.1.1 \
  simple-theme-plugin:136.v23a_15f86c53d \
  jdk-tool:63.v62d2fd4b_4793 \
  command-launcher:90.v669d7ccb_7c31 \
  windows-slaves:1.8.1
