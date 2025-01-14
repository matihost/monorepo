# Terraform :: Virtual Network

Setup minimal network resources:

* Virtual Network in resource group region - with disable default outbound connectivity (so that NAT is required)

* Subnetworks for VM and Containers (opinionated names)

* Bastion Host (along with dedicated subnet)

* Nat Gateway along with PublicIP associated with all subnetworks

* Infrastructure to run CloudShell in VNet and dedicated Storage Class Share for mounting cloud disk.

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
# setup Network resources
make run MODE=apply ENV=dev-westeurope
```
