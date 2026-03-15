# Terraform :: AKS Classic

Setup Azure Container Registry (ACR)

* Azure RBAC (aka Azure EntraID) Roles to manage K8S RBAC, with EntraId group acting as cluster-admins


## Prerequisites

* Latest Terragrunt/OpenTofu installed

* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

* Azure Subscription.

* Logged to Azure Subscription:

  ```bash
  make login
  ```

* Initialize Azure Storage Account and Container for keeping Terraform state

  ```bash
  make init
  ```

* [../azure-entraid](../azure-entraid) - installed for the same stage environment (contains resource group and policies)

* Ensure networking is setup for evn and region: [../azure-network-setup](../azure-network-setup) - installed for the same stage environment and region
Not all regions are compatible with AKS or contains desired VM sizes:


## Usage

```bash
# setup ACR registry
make run MODE=apply [ENV=dev-westeurope-shared1]

# update pull secret in currently logged ARO cluster with credentials to this repo
make update-pull-secret
```
