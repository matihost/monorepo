#!/usr/bin/env bash
set -x
export JENKINS_PLUGIN_MANAGER_VERSION="2.13.0"
export JENKINS_PLUGINS="ec2 \
  branch-api \
  pipeline-stage-view \
  workflow-job \
  workflow-aggregator \
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
  matrix-auth \
  authorize-project \
  prometheus \
  simple-theme-plugin \
  jdk-tool \
  command-launcher \
  windows-slaves"

function download_jenkins_plugin_manager_cli() {
  sudo curl -sSL "https://github.com/jenkinsci/plugin-installation-manager-tool/releases/download/${JENKINS_PLUGIN_MANAGER_VERSION}/jenkins-plugin-manager-${JENKINS_PLUGIN_MANAGER_VERSION}.jar" -o /usr/share/jenkins/jenkins-plugin-manager.jar
}

function download_jenkins_plugins() {
  # download them to intermediate location /usr/share/jenkins/ref/plugins
  # from there they need to be copied to /var/lib/jenkins/plugins during actual Jenkins EC2 startup
  # shellcheck disable=SC2086
  sudo java -jar /usr/share/jenkins/jenkins-plugin-manager.jar --clean-download-directory --latest true --plugins ${JENKINS_PLUGINS}
  sudo cp -r -p /usr/share/jenkins/ref/plugins/. /var/lib/jenkins/plugins/.
  sudo chown -R jenkins:jenkins /var/lib/jenkins/plugins
}

function configure_jenkins() {
  sudo mkdir -p /var/lib/jenkins/init.groovy.d /var/lib/jenkins/casc_configs /etc/systemd/system/jenkins.service.d
  # so that scripts works locally
  [ -e jenkins.yaml ] && {
    sudo cp jenkins.yaml /var/lib/jenkins/casc_configs
    sudo cp basic.groovy /var/lib/jenkins/init.groovy.d
    sudo cp systemd.conf /etc/systemd/system/jenkins.service.d/override.conf
  }
  # so that scripts work with Packer
  [ -e /tmp/jenkins.yaml ] && {
    sudo cp /tmp/jenkins.yaml /var/lib/jenkins/casc_configs
    sudo cp /tmp/basic.groovy /var/lib/jenkins/init.groovy.d
    sudo cp /tmp/systemd.conf /etc/systemd/system/jenkins.service.d/override.conf
  }
  sudo chown -R jenkins:jenkins /var/lib/jenkins/init.groovy.d /var/lib/jenkins/casc_configs

  sudo systemctl daemon-reload
  sudo systemctl start jenkins
  sudo systemctl stop jenkins
  sudo rm -rf /var/lib/jenkins/init.groovy.d/basic.groovy
}

# Main
sudo apt update
sudo apt -y install fontconfig jenkins
sudo systemctl enable --now jenkins
sudo systemctl stop jenkins
# shellcheck disable=SC2015
download_jenkins_plugin_manager_cli && download_jenkins_plugins && configure_jenkins || {
  echo "Unable to build Jenkins AMI"
  exit 1
}
