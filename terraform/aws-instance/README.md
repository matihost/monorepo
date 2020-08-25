# Terraform :: Sample AWS Instance

Setup single EC2 instance in default VPC (us-east-1) with Ngnix server on it.
Present basic Terraform feature

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account

```bash
aws configure
```

* Latest Terraform installed

## Usage

```bash

# deploy EC2 instance and related resources
make apply

# connects to EC2 intances Nginx
make test

# ssh to EC2 instance
make ssh

# show Terraform state along with current EC2 instance user_date startup script
make show-state

# terminates all AWS resource created with apply task
make destroy
```
