# Terraform :: EFS  deployment

Terraform scripts deploy EFS

In particular it creates:

- Regional EFS file system
- Mount Target in each private zone

## Prerequisites

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

- Latest Terraform or OpenTofu, Terragrunt installed

- Logged to AWS Account and ensure Default Region is set.

```bash
aws configure
```

## Usage

```bash
# deploys EFS
make run ENV=dev MODE=apply

# show Terraform state
make show-state ENV=dev

# mount EFS
./test/mount-efs.sgh REGION=us-east-1 EFS_FILESYSTEM_ID=....
```
