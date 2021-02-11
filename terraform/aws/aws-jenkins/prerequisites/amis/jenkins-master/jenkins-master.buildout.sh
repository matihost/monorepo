#!/usr/bin/env bash
set -x
export JENKINS_PLUGIN_MANAGER_VERSION="2.5.0"
export JENKINS_PLUGINS="ec2 \
  workflow-job:2.40 \
  workflow-aggregator:2.6 \
  credentials-binding:1.24 \
  git:4.5.2 \
  configuration-as-code:1.47 \
  timestamper:1.11.8 \
  github-branch-source:2.9.5 \
  matrix-auth:2.6.5 \
  prometheus:2.0.8 \
  simple-theme-plugin:0.6 \
  jdk-tool:1.4 \
  command-launcher:1.5 \
  jaxb:2.3.0.1 \
  branch-api:2.6.2"

function download_jenkins_plugin_manager_cli() {
  sudo curl -sSL "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${JENKINS_PLUGIN_MANAGER_VERSION}/jenkins-plugin-manager-${JENKINS_PLUGIN_MANAGER_VERSION}.jar" -o /usr/share/jenkins/jenkins-plugin-manager.jar
}

function download_jenkins_plugins() {
  # download them to intermediate location /usr/share/jenkins/ref/plugins
  # from there they need to be copied to /var/lib/jenkins/plugins during actual Jenkins EC2 startup
  # shellcheck disable=SC2086
  sudo java -jar /usr/share/jenkins/jenkins-plugin-manager.jar --plugins ${JENKINS_PLUGINS}
}

# Main
sudo apt update
sudo apt -y install jenkins
# shellcheck disable=SC2015
download_jenkins_plugin_manager_cli && download_jenkins_plugins || {
  echo "Unable to build Jenkins AMI"
  exit 1
}
