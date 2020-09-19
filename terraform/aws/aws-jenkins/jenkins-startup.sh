#!/usr/bin/env bash

# Env variables, JENKIS_* are variable used by jenkins-cli as well h
export JENKINS_URL="http://localhost:8080"
export JENKINS_USER_ID=admin
# TODO use AWS Secret Manager to retrieve password/secret upon boot
# since AWS Secret Manager is non free-tier eliglible
export ADMIN_PASS=admin
export JENKINS_JAVA_ARGS="-Djava.awt.headless=true -Xmx356m -Djava.net.preferIPv4Stack=true -Djenkins.install.runSetupWizard=false -Dcasc.jenkins.config=\/var\/lib\/jenkins\/casc_configs"
export JENKINS_PLUGINS="ec2 \
  workflow-job \
  workflow-aggregator \
  credentials-binding \
  git \
  configuration-as-code \
  timestamper \
  github-branch-source \
  matrix-auth \
  prometheus \
  simple-theme-plugin \
  jdk-tool \
  command-launcher"

function check_for_jenkins() {
  # shellcheck disable=SC2091
  until $(curl -u "${JENKINS_USER_ID}:${ADMIN_PASS}" --output /dev/null -s --head --fail "${JENKINS_URL}/login"); do
    printf '.'
    sleep 1
  done
}

function restart_jenkins() {
  echo "Restarting Jenkins"
  systemctl restart jenkins
  sleep 5
  check_for_jenkins
  echo "Jenkins is back online"
}

function add_admin_user() {
  mkdir -p /var/lib/jenkins/init.groovy.d
  script="#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.install.*;
import hudson.util.*;

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(\"${JENKINS_USER_ID}\",\"${ADMIN_PASS}\")
instance.setSecurityRealm(hudsonRealm)
instance.save()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
"
  echo -n "${script}" >/var/lib/jenkins/init.groovy.d/basic.groovy
}

function download_jenkins_cli() {
  curl -sSL -o /var/lib/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
}

function configure_casc() {
  # -Dcasc.jenkins.config=\/var\/lib\/jenkins\/casc_configs has to be added to Jenkins master JAVA_ARGS
  mkdir -p /var/lib/jenkins/casc_configs

  config_data="
security:
  scriptApproval:
    approvedSignatures:
    - \"method groovy.json.JsonSlurperClassic parseText java.lang.String\"
    - \"new groovy.json.JsonSlurperClassic\"
"
  echo -n "${config_data}" >/var/lib/jenkins/casc_configs/script-approval.yaml

  config_data="
unclassified:
  simple-theme-plugin:
    elements:
      - cssUrl:
          url: \"https://tobix.github.io/jenkins-neo2-theme/dist/neo-light.css\"
"
  echo -n "${config_data}" >/var/lib/jenkins/casc_configs/neo-theme.yaml

  config_data="
jenkins:
  systemMessage: Welcome to the Matihost CI\CD server.
"
  echo -n "${config_data}" >/var/lib/jenkins/casc_configs/welcome-message.yaml

  config_data="
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      enableCaptcha: false
      users:
      - id: \"admin\"
        name: \"${JENKINS_USER_ID}\"
        password: \"${ADMIN_PASS}\"
      - id: \"user\"
        name: \"user\"
        password: \"user\"
  authorizationStrategy:
    projectMatrix:
      permissions:
      - \"Agent/Build:admin\"
      - \"Agent/Configure:admin\"
      - \"Agent/Connect:admin\"
      - \"Agent/Create:admin\"
      - \"Agent/Delete:admin\"
      - \"Agent/Disconnect:admin\"
      - \"Agent/ExtendedRead:admin\"
      - \"Agent/ExtendedRead:authenticated\"
      - \"Credentials/Create:admin\"
      - \"Credentials/Delete:admin\"
      - \"Credentials/ManageDomains:admin\"
      - \"Credentials/Update:admin\"
      - \"Credentials/View:admin\"
      - \"Job/Build:admin\"
      - \"Job/Cancel:admin\"
      - \"Job/Configure:admin\"
      - \"Job/Create:admin\"
      - \"Job/Delete:admin\"
      - \"Job/Discover:admin\"
      - \"Job/Discover:authenticated\"
      - \"Job/ExtendedRead:admin\"
      - \"Job/Move:admin\"
      - \"Job/Read:admin\"
      - \"Job/Read:authenticated\"
      - \"Job/Workspace:admin\"
      - \"Lockable Resources/Reserve:admin\"
      - \"Lockable Resources/Unlock:admin\"
      - \"Lockable Resources/View:admin\"
      - \"Lockable Resources/View:authenticated\"
      - \"Metrics/HealthCheck:admin\"
      - \"Metrics/ThreadDump:admin\"
      - \"Metrics/View:admin\"
      - \"Metrics/View:authenticated\"
      - \"Overall/Administer:admin\"
      - \"Overall/Read:admin\"
      - \"Overall/Read:authenticated\"
      - \"Overall/SystemRead:admin\"
      - \"Run/Delete:admin\"
      - \"Run/Replay:admin\"
      - \"Run/Update:admin\"
      - \"SCM/Tag:admin\"
      - \"View/Configure:admin\"
      - \"View/Create:admin\"
      - \"View/Delete:admin\"
      - \"View/Read:admin\"
      - \"View/Read:authenticated\"
"
  echo -n "${config_data}" >/var/lib/jenkins/casc_configs/iam.yaml
}
function install_plugins() {
  # TODO use Admin token instead (create it via /configure/me )
  # jenkins-cli uses JENKINS_URL, JENKINS_USER_ID and JENKINS_API_TOKEN env variables
  export JENKINS_API_TOKEN="${ADMIN_PASS}"
  # shellcheck disable=SC2086
  java -jar /var/lib/jenkins-cli.jar install-plugin ${JENKINS_PLUGINS}
  configure_casc
  restart_jenkins
}

# Main

apt update
# that will run Jenkins immediately after installation
apt -y install jenkins

# need to perfom init configuration
# similar to https://github.com/jenkinsci/docker/issues/310
# and restart jenkins
sed -i -E "s/^(JAVA_ARGS=).+/\1\"${JENKINS_JAVA_ARGS}\"/" /etc/default/jenkins
add_admin_user
restart_jenkins
systemctl enable jenkins

# init configuration is not required
rm -rf /var/lib/jenkins/init.groovy.d/basic.groovy

download_jenkins_cli
install_plugins
