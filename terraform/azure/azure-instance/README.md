# Terraform :: VM Instnace

Setup single VM instance with Ngnix server on it.

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

* [../azure-network-setup](../azure-network-setup) - installed for the same stage environment.

## Usage

```bash
# setup VM
make run MODE=apply ENV=dev-westeurope

# connect to instance via Azure Bastion
make ssh-via-bastion
```
