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


# to test or to access other resouces inside VNet via VM

# expose TinyProxy locally to access resource inside VNet - uses az tunnel (limitations, slow)
make expose-direct-proxy-locally

# or

# expose TinyProxy locally to access resource inside VNet - uses ssh tunneling (done via az tunnel), needs 2 ports, but more resilient
make expose-proxy-via-ssh-locally

# then
# test connectivity via proxy to vm ngnix
make test

# or access any other resource in the vnet via proxy exposed on 8888 port
# to do so export proxy variables:
export http_proxy=http://localhost:8888 && export https_proxy=http://localhost:8888
# then you can curl whatever in the vm

# at then end close the proxy tunnel:

# shutdown tunneled bastion's HTTP proxy
make shutdown-local-proxy
```
