# Terraform :: Monitoring

Setup Azure monitoring infrastructure:

* Log Analytics Workspace
* Azure Monitor Workspace (aka managed Prometheus)
* Azure Managed Grafana

## Prerequisites

* Latest Terraform installed
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

* Azure Subscription. Azure FreeTier Subscription is ok.

* Logged to Azure Subscription:

  ```bash
  make login
  ```

* Initialize Azure Storage Account and Container for keeping Terraform state

  ```bash
  make init
  ```

* [../azure-entraid](../azure-entraid - installed for the same stage environment (contains resource group and policies)

## Usage

```bash
# setup Monitoring resources
make run MODE=apply ENV=dev-westeurope
```
