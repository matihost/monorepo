# Terraform :: AKS Classic

Setup Azure Kubernetes Service (AKS)

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

* Ensure networking is setup for evn and region: [../azure-network-setup](../azure-network-setup) - installed for the same stage environment and region(contains VNet and Subnets for ARO), if you create new ARO environment, you need also create this repo new environment first for the same env and region.
Not all regions are compatible with ARO or contains desired VM sizes. To select machinig region run following commands:

```bash
# select your desired region
REGION=northeurope

# check whether ARO is supported in the region
# and what version can be used for initial AKS cluster deployment
az aks get-versions --location "${REGION}"


# to check whether your region and subscription supports AKS supported VM sizes with EphemeralOS disk
az vm list-skus --location "${REGION}" --size Standard_D --all --output table
```

## Usage

```bash
# setup AKS
make run MODE=apply [ENV=dev-northeurope-shared1]

# configure kubeconfig with AKS credentials of your Azure user
make kubeconfig [ENV=dev-northeurope-shared1]
k9s
```
