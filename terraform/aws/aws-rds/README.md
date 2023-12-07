# Terraform :: RDS deployment

Terraform scripts deploy Aurora Serverless v2 Postgress database

In particular it creates:

- RDS cluster

- single RDS write instance attached to cluster

- (TODO) add option to add read instance


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

# deploy RDSs
make run ENV=dev MODE=apply

# get postgress password for RDS clusters
make get-postgres-pass ENV=dev

# get psql command to connect to DBs (from within VPC)
make get-postgres-cmd


# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
