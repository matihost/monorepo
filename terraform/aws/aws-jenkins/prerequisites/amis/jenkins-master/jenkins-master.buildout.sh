#!/usr/bin/env bash
set -x
export JENKINS_PLUGIN_MANAGER_VERSION="2.12.8"
export JENKINS_PLUGINS="ec2 \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.24 \
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
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:55.v1b_32b_6ca_f9ca \
  command-launcher:84.v4a_97f2027398 \
  windows-slaves:1.8.1"

function download_jenkins_plugin_manager_cli() {
  sudo curl -sSL "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${JENKINS_PLUGIN_MANAGER_VERSION}/jenkins-plugin-manager-${JENKINS_PLUGIN_MANAGER_VERSION}.jar" -o /usr/share/jenkins/jenkins-plugin-manager.jar
}

function download_jenkins_plugins() {
  # download them to intermediate location /usr/share/jenkins/ref/plugins
  # from there they need to be copied to /var/lib/jenkins/plugins during actual Jenkins EC2 startup
  # shellcheck disable=SC2086
  sudo java -jar /usr/share/jenkins/jenkins-plugin-manager.jar --latest true --plugins ${JENKINS_PLUGINS}
}

# Main
sudo apt update
sudo apt -y install jenkins
# shellcheck disable=SC2015
download_jenkins_plugin_manager_cli && download_jenkins_plugins || {
  echo "Unable to build Jenkins AMI"
  exit 1
}
