# Packer : AMI for Jenkins Java Agent

Build and manage AMI for Jenkins Java Agent

Use AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS with account allowing creating AMIs. You may install `.../terraform/aws-iam-linked` to install role `ami-builder` with least privileges to build AMIs

## Usage

```bash
# switch to/assume role allowing building AMI images
awsp ami-builder

# build AMI
make build

# list AMIs and accompany them EBS snapshots with prefix of AMI_NAME (default: jenkins-java-agent)
make list-amis

#clean all AMI with prefix of AMI_NAME (default: jenkins-java-agent) and accompanied them snapshot (assume EBS type AMIs)
make clean-amis
```
