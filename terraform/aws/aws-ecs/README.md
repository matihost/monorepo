# Terraform :: ECS services deployment

Terraform scripts deploy apps as ECS services

In particular it creates:

- ECS cluster

- for each application it creates

  - private ECR repository (ECR repository represents single image)

  - move image to ECR repository (TODO)

  - ECS service (with Fargate)

  - internal ALB exposing ECS service

This setup use AWS resources eligible to AWS Free Tier __only__ when possible.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

## Usage

```bash

# deploy ECS apps
make run ENV=dev MODE=apply

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
