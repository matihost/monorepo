# Terraform :: Sample AWS Instance

Setup single EC2 instance in default VPC (us-east-1) with Ngnix server on it.
Present basic Terraform feature

Use  AWS resources eliglible to AWS Free Tier __only__.

## Prerequisites

* Logged to AWS Account, for detailed instruction how to login to AWS see [../aws-iam-management](../aws-iam-management).

* Latest Terragrunt, Terraform or OpenTofu installed

* [../aws-network-setup](../aws-network-setup) - installed for `dev` env, aka installation VM in own VPC. The `default` env deploys instance in the default VPC.

## Usage

```bash
# setup all instance for particular env
make run [ENV=dev/default] [MODE=apply] [PARTITION=eusc]

# deploy single instance
make run-one ENV=dev INSTANCE=windows

# connects to EC2 intance Nginx
make test ENV=default INSTANCE=ubuntu

# ssh to EC2 instance
make ssh INSTANCE=ubuntu ENV=default

# ssh to EC2 instance over SSM SSH
make ssm-ssh INSTANCE=ubuntu ENV=default

# show Terraform state along with current EC2 instance user_date startup script
make show-state
```

## EC2 with Instana Agent

```bash
# deploy Ubuntu instance with Instana host Agent and OTEL agent forwarding logs to Instana
export INSTANA_AGENT_TOKEN="....token for agent..."
export INSTANA_AGENT_BACKEND="ingress-red-saas.instana.io:443"
export INSTANA_OTEL_BACKEND="https://otlp-red-saas.instana.io:4317"
make run-one INSTANCE=instana-ubuntu ENV=dev MODE=apply

# login to
make ssm-ssh INSTANCE=instana-ubuntu

# generate info logs
((i=0)); while true; do ((i++)); (( $i % 1000 == 0 )) && sleep 1; logger -p user.info "info sample $i"; done

# generate error logs
((i=0)); while true; do ((i++)); (( $i % 1000 == 0 )) && sleep 1; logger -p user.err "error sample $i"; done
```
