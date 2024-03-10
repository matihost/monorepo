# Terraform :: Sample AWS Instance

Setup single EC2 instance in default VPC (us-east-1) with Ngnix server on it.
Present basic Terraform feature

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account, for detailed instruction how to login to AWS see [../aws-iam](../aws-iam).

* Latest Terragrunt, Terraform or OpenTofu installed

* * [../aws-network-setup](../aws-network-setup) - installed for `dev` env, aka installation VM in own VPC. The `default` env deploys instance in the default VPC.

## Usage

```bash

# setup free-tier eliglible Ubuntu instance
make run [ENV=dev] [MODE=apply]

# connects to EC2 intance Nginx
make test

# ssh to EC2 instance
make ssh

# ssh to EC2 instance over SSM SSH
make ssm-ssh

# show Terraform state along with current EC2 instance user_date startup script
make show-state

# terminates all AWS resource created with apply task
make destroy
```
