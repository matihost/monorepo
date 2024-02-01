# Minimal IBM Cloud IAM resources

Terraform scripts creating:

- resource group with name of environment (aka `dev`)

## Prerequisites

- IBM Cloud CLI installed along with VPC Infrastructure plugin

```bash
# to install https://github.com/IBM-Cloud/ibm-cloud-cli-release for Linux

curl -fsSL "https://clis.cloud.ibm.com/install/$([[ "$(uname -a)" == "Darmin"* ]] && echo "osx" || echo "linux" )" | sh

# list available ibmcloud CLI plugins
ibmcloud plugin repo-plugins

# install ibmcloud plugin for "is" commands
ibmcloud plugin install is -f


# to later update cli and all plugins
ibmcloud update
ibmcloud plugin update --all
```

- Logged to IBM Cloud CLI and generated IBM Cloud API key

```bash
# login to IBM SSO, provide default region, for example: eu-de
make ibm-authentication
```

- Latest OpenTofu, Terragrunt, jq installed

```bash
# for Mac
brew install opentofu terragrunt jq make
```

## Usage

```bash
# setup IAM
make run ENV=dev MODE=apply

# show Terraform state
make show-state

# terminates all resources created with run with apply mode
make destroy
```
