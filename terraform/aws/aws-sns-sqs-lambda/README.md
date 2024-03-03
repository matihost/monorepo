# Terraform :: Fan Out Example with SNS, SQS and Lambda

Terraform scripts deploy FanOut example with converting images into different format thumbnails

In particular it creates:

- S3 for images along with notification to SNS topic on images .jpg creation in "ingest" directory

- SNS topic with 3 subscription to SQS queues

- 3 SQS queues with lambda triggers

- 3 Lambdas which makes different format of the S3 image.

This setup use AWS resources eligible to AWS Free Tier __only__ when possible.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform/Open Tofu and Terragrant installed

## Usage

```bash

# deploy FanOut example (SNS, SQS, Lambda)
make run ENV=dev MODE=apply


# show Terragrunt state
make show-state

# terminates all AWS resource created with apply task
make run ENV=dev MODE=destroy
```
