#!/usr/bin/env bash


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
  chown jenkins:jenkins /var/lib/jenkins/casc_configs/jenkins_credentials.yaml

# Use ACCEPT-NEW strategy because of https://issues.jenkins-ci.org/browse/JENKINS-62724
# (it takes 5-10 min to connect to instance)
# and since it is only Jenkins Master able to connect to Agent (via SecGroup limit)
# the risk of MiM attack is minimal
#
# Use the same AZ as Jenkins Master to reduce cost of data transfer
# (traffic between AZs is not free-tier eliglible)
#
  config_data="
jenkins:
  clouds:
  - amazonEC2:
      name: \"aws\"
      region: \"us-east-1\"
      sshKeysCredentialsId: \"jenkins-key\"
      templates:
      - ami: \"${jenkins_agent_ami}\"
        amiType:
          unixData:
            rootCommandPrefix: \"sudo\"
            sshPort: \"22\"
        associatePublicIp: false
        connectBySSHProcess: true
        connectionStrategy: PRIVATE_IP
        deleteRootOnTermination: true
        description: \"${jenkins_name}-agent\"
        ebsEncryptRootVolume: DEFAULT
        ebsOptimized: false
        hostKeyVerificationStrategy: ACCEPT_NEW
        idleTerminationMinutes: \"30\"
        initScript: |-
          #!/usr/bin/env bash

           echo \"Jenkins Agent with label: ${jenkins_name} from AMI: ${jenkins_agent_ami} has been started\"
        javaPath: \"java\"
        labelString: \"${jenkins_name}\"
        launchTimeoutStr: \"900\"
        maxTotalUses: -1
        metadataEndpointEnabled: true
        metadataHopsLimit: 1
        metadataSupported: true
        metadataTokensRequired: false
        minimumNumberOfInstances: 1
        minimumNumberOfSpareInstances: 0
        mode: NORMAL
        monitoring: false
        numExecutors: 2
        remoteAdmin: \"ubuntu\"
        remoteFS: \"/home/ubuntu/agent\"
        securityGroups: \"${jenkins_agent_security_group}\"
        stopOnTerminate: false
        subnetId: \"${jenkins_agent_subnets}\"
        t2Unlimited: false
        tags:
        - name: \"Name\"
          value: \"${jenkins_name}-agent\"
        tenancy: Default
        type: T3Micro
        useEphemeralDevices: false
      useInstanceProfileForCredentials: true"
  echo -n "$${config_data}" >/var/lib/jenkins/casc_configs/ec2.yaml
  chown jenkins:jenkins /var/lib/jenkins/casc_configs/ec2.yaml
}


# Main

configure_ec2_plugin
systemctl enable jenkins --now
# TODO force reload casc:
# https://github.com/jenkinsci/configuration-as-code-plugin/blob/master/docs/features/configurationReload.md
