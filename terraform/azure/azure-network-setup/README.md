# Terraform :: Virtual Network

Setup minimal network resources:

* Virtual Network in resource group region - with disable default outbound connectivity (so that NAT is required)

* 3 Subnetworks

* Nat Gateway along with PublicIP associated with all subnetworks

## Prerequisites

* Latest Terraform installed
* [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt)

* Azure Subscription. Azure FreeTier Subscription is ok.

* Logged to Azure Subscription.

* Initialize Azure Storage Account and Container for keeping Terraform state

  ```bash
  make init
  ```

## Usage

```bash
# setup IAM resources
make run MODE=apply
```
