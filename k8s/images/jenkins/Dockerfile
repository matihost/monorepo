FROM jenkins/jenkins:2.401.1
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api:2.1109.vdf225489a_16d \
  pipeline-stage-view:2.32 \
  kubernetes:3937.vd7b_82db_e347b_ \
  workflow-job:1308.v58d48a_763b_31 \
  workflow-aggregator:596.v8c21c963d92d \
  cloudbees-disk-usage-simple:182.v62ca_0c992a_f3 \
  credentials:1254.vb_96f366e7b_a_d \
  credentials-binding:604.vb_64480b_c56ca_ \
  docker-commons:419.v8e3cd84ef49c \
  docker-workflow:563.vd5d2e5c4007f \
  git:5.1.0 \
  configuration-as-code:1647.ve39ca_b_829b_42 \
  timestamper:1.25 \
  github-branch-source:1728.v859147241f49 \
  github-oauth:0.39 \
  ldap:682.v7b_544c9d1512 \
  google-login:1.7 \
  matrix-auth:3.1.8 \
  authorize-project:1.7.0 \
  prometheus:2.2.3 \
  simple-theme-plugin:160.vb_76454b_67900 \
  jdk-tool:63.v62d2fd4b_4793 \
  command-launcher:100.v2f6722292ee8 \
  windows-slaves:1.8.1
