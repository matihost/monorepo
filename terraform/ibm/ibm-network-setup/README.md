# Minimal IBM CLoud recommended network setup

Terraform scripts creating:

- VPC with subnets

- bastion with public IP and ssh access, proxy being installed

Bastion node exposes only SSH to computer which execute Terraform script.

- (Optionally) plus sample webserver instances in private subnets.

Access to private webserver via HTTP is possible via proxy on bastion - which can be accessed after setup SSH tunnel on bastion.

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
# setup VPC
make run ENV=dev MODE=apply

# ssh to bastion instance
make ssh

# show Terraform state
make show-state

# terminates all resource created with run apply task
make destroy
```
