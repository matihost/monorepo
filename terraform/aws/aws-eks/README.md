# Terraform :: EKS  deployment

Terraform scripts deploy ROSA

In particular it creates:

- EKS with Auto mode

## Prerequisites

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

- Latest Terraform or OpenTofu, Terragrunt installed

- jq tool installed

- EKS CTL CLI installed (optionally):

```bash
curl -sSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar -zx -o eksctl
sudo mv eksctl /usr/local/bin
```

- Logged to AWS Account and ensure Default Region is set.

```bash
aws configure
```

## Usage

```bash

# deploys EKS
make run ENV=dev MODE=apply

# show Terraform state
make show-state ENV=dev
```

## Day 2 Operations

### Login to cluster via commandline

```bash
# create ~/.kube/config entry for EKS
make kubeconfig

# open the best k8s dashboard
k9s
```
