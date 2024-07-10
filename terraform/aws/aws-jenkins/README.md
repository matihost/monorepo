# Terraform :: Setup Jenkins Master instance

Setup single Jenkins EC2 instance in default VPC (us-east-1)

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account

```bash
aws configure
```

* Latest Terraform installed

* The terraform variable: `instance_profile` (default: `jenkins-master`) is already deployed IAM Role.
  The role have to allow acces to create EC2 instances. It will applied on Jenkins Master EC2 instance so that it can spin Jenkins Agents as EC2 instances. It can be achieved by install `..\aws-iam-linked` terraform script before.

* AMIs for Jenkins Master and Agent are already build. Check and build `prerequisites/amis/...`

## Usage

```bash

# deploy Jenkins EC2 master instance and related resources
make run MODE=apply [ENV=dev-arm]


# terminates all AWS resource for Jenkins master,
# prerequisite: terminate all EC2 jenkins-agent instances- otherwise security group for agents cannot be destroyed
# Warning: it does not destroy Jenkins Master nor Agent AMIs!
# In order to destroy them run `make clean-amis` in `prerequisites/amis/...` directories.
make destroy-jenkins-agents  [ENV=dev-arm]
make run MODE=destroy [ENV=dev-arm]


# open web browser with Jenkins instance
# use login: admin and password: the one you provided to PASS variable during make apply
make open-jenkins [ENV=dev-arm]

# ssh to Jenkins EC2 instance
make ssh [ENV=dev-arm]


# recreate Jenkins VM instance to ensure its latest LaunchTemplate is used
# use it when you run 'make apply' for the second and next time
# make apply manages LaunchTemplate and AutoScalling Group resources - so it does not recreate VMs directly
# scaling down/up has to be triggered manually
# this task scaled down ASG to 0 (aka destroy VM with Jenkisn Master)
# and then scale up - to spin new fresh Jenkins VM instance
make recreate-instance [ENV=dev-arm]

# show  state along with current EC2 instance user_date startup script
make show-state
```
