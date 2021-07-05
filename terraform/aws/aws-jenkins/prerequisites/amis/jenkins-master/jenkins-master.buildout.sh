#!/usr/bin/env bash
set -x
export JENKINS_PLUGIN_MANAGER_VERSION="2.10.0"
export JENKINS_PLUGINS="ec2 \
  workflow-job:2.41 \
  workflow-aggregator:2.6 \
  cloudbees-disk-usage-simple:0.10
  credentials:2.5 \
  credentials-binding:1.26 \
  git:4.7.2 \
  configuration-as-code:1.51 \
  timestamper:1.13 \
  github-branch-source:2.11.1 \
  github-oauth:0.33 \
  matrix-auth:2.6.7 \
  prometheus:2.0.10 \
  simple-theme-plugin:0.6 \
  jdk-tool:1.5 \
  command-launcher:1.6 \
  jaxb:2.3.0.1 \
  branch-api:2.6.4"

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
