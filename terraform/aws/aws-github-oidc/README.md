# Terraform :: AWS GitHub OIDC provider

Terraform scripts creating:

- OIDC provider allowing github assume role on behalf of GitHub Actions invocation

- OIDC role which can be assumed by GitHub action for selected GitHub repositories

This setup use AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

## Usage

```bash
# setup OIDC provider and role
make run ENV=dev MODE=apply

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
