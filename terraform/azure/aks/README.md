# Terraform :: AKS Classic

Setup Azure Kubernetes Service (AKS) along with the following addons:

* Azure RBAC (aka Azure EntraID) Roles to manage K8S RBAC, with EntraId group acting as cluster-admins

* Integration with Managed Grafana, Managed Monitor Workspaces (aka Managed Prometheus)
  WARNING: still requires [DCR configuration](https://techcommunity.microsoft.com/blog/azureinfrastructureblog/how-to-set-up-data-collection-rules-dcr-for-azure-kubernetes-service-aks/4411415) for fully operational state

* Gatekeeper and external secret operator addons

* Namespaces setup. Each namespace contains:
  * dedicated Azure KeyVault and External Secret Operator Store - to sync NS dedicated Azure KeyVault Secrets with K8S Secrets resources.
  * Automatically created external secret `all-secrets` containing all Secrets from associated with NS KeyVault.
  * EntraID groups for each namespace for view and edit RBAC binding.
  * Workload Identity assigning `app` K8S SA to User Assigned Identity (being part of NS edit EntraId group)

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

```bash
# select your desired region
REGION=northeurope

# check whether AKS is supported in the region
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
# with non-interactive mode (by default interactive, device logon method is used)
make kubeconfig [ENV=dev-northeurope-shared1]
k9s


```

## FAQ

### I can login to AKS but I get authorization errors on every K8S command

I successfully authenticated to AKS but I get authorization error:

```bash
make kubeconfig [ENV=dev-northeurope-shared1]
Merged "dev-neu-shared1" as current context in /home/xxx/.kube/config

kubectx
dev-neu-shared1

kubectl version
To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code XXXXXX to authenticate.

kubectl get no
Error from server (Forbidden): nodes is forbidden: User "......." cannot list resource "nodes" in API group "" at the cluster scope: User does not have access to the resource in Azure. Update role assignment to allow access.
```

By default only Azure entity who created AKS is a member of the cluster-admin group associated with AKS cluster.
Ensure your Azure user is member of that group in EntraId.

Call to get the name of the group id associated with AKS cluster:

```bash
make get-cluster-admin-entraid-group-name [ENV=dev-northeurope-shared1]
```

Then ensure your a member of that group.
