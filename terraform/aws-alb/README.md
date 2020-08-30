# Terraform :: Application Load Balancer usage example

Terraform scripts creates:

- launch template for webserver (nginx)

- autoscalling group

- targetgroup for ALB

- Application Load Balancer (ALB)  (TODO)

This setup use AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

## Usage

```bash

# deploy webservers ALB
make apply

# test webservers via ALB
make test

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
