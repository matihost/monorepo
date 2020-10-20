# Terraform :: Sample Lambda Function

Setup a Lambda Function in default VPC (us-east-1) emulating a client hitting EC2 instance.

Use AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account

```bash
aws configure
```

* `make prepare` is invoked to create S3 bucket and populate lambda function object

* `cd ../aws-iam && make apply` - aka `aws-iam` TF is run to create necessary permission for both LimitedAdmin group to allow operating on Lambda and creating `lambda-basic` role so that it can be used by Lambda function

* `cd ../aws-instance && make apply` - aka `aws-instance` TF is run to create simple EC2 instance which Lambda is hitting.

* Latest Terraform installed

## Usage

```bash

# prepare S3 bucket required by Lambda
make prepare

# setup Lambda function testing EC2 instance HTTP port
make apply

# invoke Lambda programatically
make test

# show Terraform state
make show-state

# to rebuild lambda .zip file (to redeploy new version of sli-synthetic-client.py)
make build && make apply

# terminates all AWS resource created with apply task, it also terminates S3 bucket done by make prepare
make destroy
```
