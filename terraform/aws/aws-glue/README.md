# Terraform :: Glue services deployment

TODO

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

## Usage

```bash

# deploy Glue jobs
make run ENV=dev MODE=apply

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
