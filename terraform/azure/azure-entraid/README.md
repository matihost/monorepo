# Terraform :: Minimal set of Entra ID resources for Azure

Setup minimal IAM resources:

* Resource Group

* Policies on Resource Group level to enforce resource regions and VM sizes

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

## Usage

```bash
# setup IAM resources
make run MODE=apply
```
