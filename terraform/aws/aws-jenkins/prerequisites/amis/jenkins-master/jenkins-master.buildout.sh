#!/usr/bin/env bash
set -x
export JENKINS_PLUGIN_MANAGER_VERSION="2.12.8"
export JENKINS_PLUGINS="ec2 \
  branch-api:2.1046.v0ca_37783ecc5 \
  pipeline-stage-view:2.24 \
  workflow-job:1203.v7b_7023424efe \
  workflow-aggregator:590.v6a_d052e5a_a_b_5 \
  cloudbees-disk-usage-simple:0.10 \
  credentials:1139.veb_9579fca_33b_\
  credentials-binding:523.vd859a_4b_122e6 \
  docker-commons:1.19 \
  docker-workflow:1.29 \
  git:4.11.3 \
  configuration-as-code:1464.vd8507b_82e41a_ \
  timestamper:1.18 \
  github-branch-source:1656.v77eddb_b_e95df \
  github-oauth:0.39 \
  ldap:2.10 \
  matrix-auth:3.1.5 \
  authorize-project:1.4.0 \
  prometheus:2.0.11 \
  simple-theme-plugin:103.va_161d09c38c7 \
  jdk-tool:1.5 \
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
