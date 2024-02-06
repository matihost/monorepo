# IBM Cloud Load Balancers usage example

Terraform scripts creating:

- Instance group spanning all VPC subnets and attach Private Application LoadBalancer to it

- Single zone instance group and attach Network LoadBalancer to it (NLB are zonal only)

TODOs:

- how to attach iam_trusted_profile? (IG does not support instance templated with default iam trusted profile)

- public LBs

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

- The scripts assume that [ibm-network-setup](../ibm-network-setup) is already deployed (aka private networking is present).

## Usage

```bash
# setup Instance Groups and LBs
make run ENV=dev MODE=apply

# ssh to bastion instance
make ssh

# show Terraform state
make show-state

# terminates all resource created with run apply task
make destroy
```
