#!/usr/bin/env bash

# Env variables, JENKIS_* are variable used by jenkins-cli as well h
export JENKINS_URL="http://localhost:8080"
export JENKINS_USER_ID=admin
# TODO use AWS Secret Manager to retrieve password/secret upon boot
# since AWS Secret Manager is non free-tier eliglible
export ADMIN_PASS='${admin_password}'
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
  until $(curl -u "$${JENKINS_USER_ID}:$${ADMIN_PASS}" --output /dev/null -s --head --fail "$${JENKINS_URL}/login"); do
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

function init_config() {
  # need to perfom init configuration
  # similar to https://github.com/jenkinsci/docker/issues/310
  # and restart jenkins
  sed -i -E "s/^(JAVA_ARGS=).+/\1\"$${JENKINS_JAVA_ARGS}\"/" /etc/default/jenkins
  mkdir -p /var/lib/jenkins/init.groovy.d
  script="#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.install.*;
import hudson.util.*;

def instance = Jenkins.getInstance()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(\"$${JENKINS_USER_ID}\",\"$${ADMIN_PASS}\")
instance.setSecurityRealm(hudsonRealm)
instance.save()

instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)
instance.save()
"
  echo -n "$${script}" >/var/lib/jenkins/init.groovy.d/basic.groovy

  restart_jenkins

  # init configuration is not required after being applied after restart
  rm -rf /var/lib/jenkins/init.groovy.d/basic.groovy
}

function download_jenkins_cli() {
  curl -sSL -o /var/lib/jenkins-cli.jar http://localhost:8080/jnlpJars/jenkins-cli.jar
}

function configure_common_casc() {
  # -Dcasc.jenkins.config=\/var\/lib\/jenkins\/casc_configs has to be added to Jenkins master JAVA_ARGS
  mkdir -p /var/lib/jenkins/casc_configs

  config_data="
security:
  scriptApproval:
    approvedSignatures:
    - \"method groovy.json.JsonSlurperClassic parseText java.lang.String\"
    - \"new groovy.json.JsonSlurperClassic\"
"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/script-approval.yaml

  config_data="
unclassified:
  simple-theme-plugin:
    elements:
      - cssUrl:
          url: \"https://tobix.github.io/jenkins-neo2-theme/dist/neo-light.css\"
"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/neo-theme.yaml

  config_data="
jenkins:
  systemMessage: Welcome to the Matihost CI\CD server.
"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/welcome-message.yaml

  config_data="
jenkins:
  securityRealm:
    local:
      allowsSignup: false
      enableCaptcha: false
      users:
      - id: \"admin\"
        name: \"$${JENKINS_USER_ID}\"
        password: \"$${ADMIN_PASS}\"
      - id: \"user\"
        name: \"user\"
        password: \"$${ADMIN_PASS}\"
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
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/iam.yaml
}


function configure_ec2_plugin(){
  cp /home/ubuntu/.ssh/id_rsa /var/lib/jenkins/secrets
  chown jenkins:jenkins /var/lib/jenkins/secrets/id_rsa
  config_data="
credentials:
  system:
    domainCredentials:
    - credentials:
      - basicSSHUserPrivateKey:
          description: \"jenkins private key\"
          id: \"jenkins-key\"
          privateKeySource:
            directEntry:
              privateKey: \"\$${readFile:/var/lib/jenkins/secrets/id_rsa}\"
          scope: GLOBAL
          username: \"jenkins\"
"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/jenkins_credentials.yaml

# Use ACCEPT-NEW strategy because of https://issues.jenkins-ci.org/browse/JENKINS-62724
# (it takes 5-10 min to connect to instance)
# and since it is only Jenkins Master able to connect to Agent (via SecGroup limit)
# the risk of MiM attack is minimal
#
# Use the same AZ as Jenkins Master to reduce cost of data transfer
#(traffic between AZs is not free-tier eliglible)
#
  config_data="
jenkins:
  clouds:
  - amazonEC2:
      cloudName: \"AWS Cloud\"
      region: \"us-east-1\"
      sshKeysCredentialsId: \"jenkins-key\"
      templates:
      - ami: \"${ami}\"
        amiType:
          unixData:
            rootCommandPrefix: \"sudo\"
            sshPort: \"22\"
        associatePublicIp: false
        connectBySSHProcess: true
        connectionStrategy: PRIVATE_IP
        deleteRootOnTermination: true
        description: \"ubuntu-basic\"
        ebsOptimized: false
        hostKeyVerificationStrategy: ACCEPT_NEW
        idleTerminationMinutes: \"30\"
        initScript: |-
          #!/usr/bin/env bash

          sudo apt update
          sudo apt -y install openjdk-8-jdk
        labelString: \"aws-ubuntu\"
        launchTimeoutStr: \"900\"
        maxTotalUses: -1
        minimumNumberOfInstances: 0
        minimumNumberOfSpareInstances: 0
        mode: NORMAL
        monitoring: false
        numExecutors: 1
        remoteAdmin: \"ubuntu\"
        remoteFS: \"/home/ubuntu/agent\"
        securityGroups: \"jenkins_agent\"
        stopOnTerminate: false
        t2Unlimited: false
        tags:
        - name: \"Name\"
          value: \"jenkins-agent\"
        type: T2Micro
        useDedicatedTenancy: false
        useEphemeralDevices: false
        zone: "${zone}"
      useInstanceProfileForCredentials: true
"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/ec2.yaml
}


function install_plugins() {
  # TODO use Admin token instead (create it via /configure/me )
  # jenkins-cli uses JENKINS_URL, JENKINS_USER_ID and JENKINS_API_TOKEN env variables
  export JENKINS_API_TOKEN="$${ADMIN_PASS}"

  # Fixes possible error:
  # ec2 is neither a valid file, URL, nor a plugin artifact name in the update center
  # No update center data is retrieved yet from: https://updates.jenkins.io/update-center.json
  mkdir -p /var/lib/jenkins/updates
  wget http://updates.jenkins-ci.org/update-center.json -qO- | sed '1d;$d' >/var/lib/jenkins/updates/default.json
  chmod 666 /var/lib/jenkins/updates/default.json

  # shellcheck disable=SC2086
  java -jar /var/lib/jenkins-cli.jar install-plugin $${JENKINS_PLUGINS}
  configure_common_casc
  configure_ec2_plugin
  restart_jenkins
}

# Main

apt update
# that will run Jenkins immediately after installation
apt -y install jenkins

init_config

systemctl enable jenkins

download_jenkins_cli
install_plugins
