FROM jenkins/jenkins:2.387.3
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1071.v1a_188a_562481 \
  pipeline-stage-view:2.32 \
  kubernetes:3923.v294a_d4250b_91 \
  workflow-job:1292.v27d8cc3e2602 \
  workflow-aggregator:596.v8c21c963d92d \
  cloudbees-disk-usage-simple:178.v1a_4d2f6359a_8 \
  credentials:1254.vb_96f366e7b_a_d \
  credentials-binding:604.vb_64480b_c56ca_ \
  docker-commons:419.v8e3cd84ef49c \
  docker-workflow:563.vd5d2e5c4007f \
  git:5.0.1 \
  configuration-as-code:1625.v27444588cc3d \
  timestamper:1.25 \
  github-branch-source:1703.vd5a_2b_29c6cdc \
  github-oauth:0.39 \
  ldap:673.v034ec70ec2b_b_ \
  google-login:1.7 \
  matrix-auth:3.1.7 \
  authorize-project:1.5.1 \
  prometheus:2.2.2 \
  simple-theme-plugin:160.vb_76454b_67900 \
  jdk-tool:63.v62d2fd4b_4793 \
  command-launcher:100.v2f6722292ee8 \
  windows-slaves:1.8.1
