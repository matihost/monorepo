# Terraform :: Minimal AWS recommended setup with private subnet

Terraform scripts creating:

- private subnet

- bastion in public subnet

- NAT instance in public subnet to allow private subnet access internet.
  In production NAT Gateway should be used. NAT instance is AWS free-tier eliglibe version of NAT Gateway.

- (Optionally) plus sample webserver instance in private subnet.

Bastion node exposes only SSH to computer which execute Terraform script.

Access to private webserver via HTTP is possible via proxy on bastion - which can be accessed after setup SSH tunnel on bastion.

This setup use AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

- Logged to AWS Account

```bash
aws configure
```

- Latest Terraform installed

## Usage

```bash

# deploy resources, w/o sample webserver in private subnetwork, only networking resources
make apply

# deploy resources along with sample webserver in private subnetwork
make apply WITH_SAMPLE_INSTANCE=true

# ssh to bastion EC2 instance
make bastion-ssh

# test private webserver, it creates tunnel to Bastion's Proxy and connects via it to private webserver intance
make test

# ssh to bastion EC2 instance
make nat-ssh


# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```
