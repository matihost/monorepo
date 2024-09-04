FROM jenkins/jenkins:2.462.2
RUN jenkins-plugin-cli --verbose --latest true --plugins \
  branch-api \
  pipeline-stage-view \
  kubernetes \
  workflow-job \
  workflow-aggregator\
  cloudbees-disk-usage-simple \
  credentials \
  credentials-binding \
  docker-commons \
  docker-workflow \
  git \
  configuration-as-code \
  timestamper \
  github-branch-source \
  github-oauth \
  ldap \
  google-login \
  matrix-auth \
  authorize-project \
  prometheus \
  simple-theme-plugin \
  jdk-tool \
  command-launcher \
  windows-slaves
