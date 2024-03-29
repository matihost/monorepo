# IBM Cloud Load Balancers usage example

The following repo contains:

- Terraform/OpenTofu module creating:

  - Private & Public Application LoadBalancer along with separate Instance group spanning all VPC subnets
  - Private & Public Network LoadBalancer along with separate Instance group single VPC subnet
  - Instance template for private access and separated one for public access

- Deployment is realized via either:

  - Terragrunt with local file state management (this readme)

  or

  - IBM Schemantics structure for deployment (see [schemantics](schemantics/README.md) directory for instructions how to deploy this repo with IBM Cloud Schemantics.

Warnings:

- You may encounter blow during setup, repeat the run to solve it. LB is switching the mode to updating (w/o saying the reason) and during that time you cannot change anything related to LB.

  ```txt
  "code": "load_balancer_update_conflict",
  "message": "The load balancer with ID 'r010-d1e94aba-805e-4e13-a1d1-fbebb94fb24e' cannot be updated because its status is 'UPDATE_PENDING'.",
  "more_info": "https://cloud.ibm.com/docs/vpc?topic=vpc-rias-error-messagesload_balancer_update_conflict"
  ```

- NLB are zonal only

- NLB are pass though LB - so security group on Instance has to accept public ip access

- ALB are proxy based located in your VPC - so security group on Instance can limit traffic only from VPC.

- Instance Group can be applied only to single LB.

- Instance Template security group cannot be overridden in Instance Group - hence Instance Group to be used by public NLB vs private has to differ.

TODOs:

- how to attach iam_trusted_profile? (IG does not support instance templated with default iam trusted profile)

## Prerequisites

- IBM Cloud CLI installed along with VPC Infrastructure plugin

```bash
# to install https://github.com/IBM-Cloud/ibm-cloud-cli-release for Linux

curl -fsSL "https://clis.cloud.ibm.com/install/$([[ "$(uname -a)" == "Darmin"* ]] && echo "osx" || echo "linux" )" | sh

# list available ibmcloud CLI plugins
ibmcloud plugin repo-plugins

# install ibmcloud plugin for "is" commands
ibmcloud plugin install is -f
ibmcloud plugin install sch -f

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
