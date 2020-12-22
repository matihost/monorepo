# Packer : AMI for Jenkins Java Agent

Build and manage AMI for Jenkins Java Agent

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS with account allowing creating AMIs. You may install `.../terraform/aws-iam` to install role `ami-builder` with least privilidges to build AMIs

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

# spin test EC2 instance from the latest AMI present in the account in the region
# switch back to account allowing create instance
awsp default
make test-instance

# then to ssh to it to check whether everything is in order (TODO do some automation here)
make test-ssh

# clean after tests, shutdown EC2 test instance
make test-slean
```
