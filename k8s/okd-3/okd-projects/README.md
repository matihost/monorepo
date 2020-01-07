# OpenShift Projects Management

Various [OpenShift Origin](https://www.okd.io/) scripts, project deployment.

## Prerequisites

OKD or Minishift installation.

See [../ansible/okd-installation/okd-3.10](../ansible/okd-installation/okd-3.10) for instruction how to install sample OKD on 3 VirtualBox VMs.

## Usage

```bash
# login as admin, required for remaining steps
make login

# show cluster status
make cluster-status

# deploy learning project in logged OKD cluster
cd learning
make deploy.yaml
```