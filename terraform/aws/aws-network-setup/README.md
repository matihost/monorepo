# Minimal AWS recommended setup with private subnet

Terraform scripts creating:

- private subnet

- bastion in public subnet

- NAT instance in public subnet to allow private subnet access internet.
  In production NAT Gateway should be used. NAT instance is AWS free-tier eligible version of NAT Gateway.

- SSM enablemend.

- SSM related VPC endpoints - to be able to SSM to private only EC2 instances.

  **Warning**: configured via `create_ssm_private_access_vpc_endpoints` variable flag. VPC endpoint costs 0.01$ per instance per hour.
  Private SSM access requires 6 VPC endpoints - which leads to 4.32 $ minimal cost for VPC endpoints per day.

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
# setup VPC
make run ENV=dev MODE=apply

# ssh to bastion EC2 instance
make ssh

# test private webserver, it creates tunnel to Bastion's Proxy and connects via it to private webserver intance
make test

# ssh to NAT EC2 instance
make nat-ssh

# ssh to webserver instance over SSM
make webserver-ssm-ssh

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make destroy
```

## Setup VPC peering

In order to setup VPC peering between all VPC within environment (within single AWS account only),
you need to:

```bash
# deploy all VPC w/o peering first
make run ENV=dev MODE=apply

# change stage/dev/us-east-1/terragrunt.hcl by uncommenting vpc_peering_regions
# then
make run-one ENV=dev REGION=us-east-1 MODE=apply

# change stage/dev/us-central-1/terragrunt.hcl by uncommenting   vpc_peering_acceptance_regions
# then
make run-one ENV=dev REGION=us-central-1 MODE=apply

# change stage/dev/us-east-1/terragrunt.hcl by uncommenting finish_peering
# then
make run-one ENV=dev REGION=us-east-1 MODE=apply
```
