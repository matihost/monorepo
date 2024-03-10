# Terraform :: Sample Lambda Function

Setup a Lambda Function in default VPC (us-east-1) emulating a client hitting EC2 instance.

Optionally setup the Lambda triggers:

* CloudWatch Event Rule Trigger - invoke lamda every minute

* API Gateway - expose lambda as REST endpoint

## Prerequisites

* Logged to AWS Account, for detailed instruction how to login to AWS see [../aws-iam](../aws-iam).

* [../aws-instance](../aws-instance) - installed

* Latest Terragrunt, Terraform or OpenTofu installed

## Usage

```bash
# deploy API Gateway exposing Lambda along with CloudWatch Event trigger
make run [ENV=dev] [MODE=apply]

# invoke Lambda programatically
make test

# invoke Lambda via API Gateway endpoint
make test-api

# show Terragrunt state
make show-state
```
