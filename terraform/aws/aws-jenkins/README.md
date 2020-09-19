# Terraform :: Setup Jenkins Master instance

Setup single Jenkins EC2 instance in default VPC (us-east-1)

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account

```bash
aws configure
```

* Latest Terraform installed

## Usage

```bash

# deploy Jenkins EC2 instance and related resources
make apply

# recreate Jenkins VM instance to ensure its latest LaunchTemplate is used
# use it when make apply was run for the next time - as it is manager LaunchTemplate and AutoScalling Group
# make apply will not recrete VM automatically when it is run for the second time - it has to be triggered manually
make recreate-instance

# tests enkins instance
make test

# ssh to Jenkins EC2 instance
make ssh

# show Terraform state along with current EC2 instance user_date startup script
make show-state

# terminates all AWS resource created with apply task
make destroy
```
