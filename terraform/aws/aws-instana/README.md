# Terraform :: Instana configuration

Terraform scripts deploy Instana configuration

In particular it creates:

- AWS EC2 instance with  [Instana AWS Cloud Service Agent](https://www.ibm.com/docs/en/instana-observability/current?topic=agents-amazon-web-services-aws) (single dedicated EC2 per region). It is infrastructure agent for serverless services like S3, Lambda, API Gateway etc.

- RBAC `admin` group - after creation - you need to assing users manually from Instana UI

- Sample Custom Dashboard (with `admin` and build-in `Owner` groups as writers)

In order to fully utilize Instana also install `host` agents, sample EC2 instance with Instana agent installation: [../aws-instance/stage/dev/ubuntu](../aws-instance/stage/dev/ubuntu/terragrunt.hcl)

## Prerequisites

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

- Latest Terraform or OpenTofu, Terragrunt installed

- Logged to AWS Account and ensure Default Region is set.

- Instana Tenant. [Free Trial](https://www.ibm.com/products/instana) is ok.

  - Instana Free Trial is 14 days and requires IBM id.
  - Instana Free Trial creates SAAS endpoint in the form of: [https://<tenant>-<org>.instana.io](https://<tenant>-<org>.instana.io) (which you can use for INSTANA_ENDPOINT env variable).
  - You receive an invitation email with build-in token which you can use to setup Instana Agents (aka for INSTANA_AGENT_TOKEN).
  - Your Ibm ID is your usename for https://instana.io - with first login - you need to reset password.
  After successfull login your are automaticall redirected to your Instana Org/Tenant URL: [https://<tenant>-<org>.instana.io](https://<tenant>-<org>.instana.io)
  - Warning: It may take even 2 h after you receive invitation email to make your org/tenant operational.

- Instana API token.
  - Login to your org/tenant via [https://instana.io](https://instana.io).
  - Go to Settings / Security Access / API Tokens / New API Token / Add all permissions - this is your API token which - you can use for INSTANA_API_TOKEN environment variable in scripts.

- Check your [agent ingress endpoint](https://www.ibm.com/docs/en/instana-observability/current?topic=planning-preparing-endpoints-keys#endpoints-for-the-host-and-cloud-service-agents) depending on the location of your deployments. This is the enpoint used by Agent to send telemetry information (aka INSTANA_AGENT_BACKEND env variable)

- Prepare environment variables:

```bash
export INSTANA_API_TOKEN="...Instana API token...."
export INSTANA_ENDPOINT="<org>>-<tenant>.instana.io"
export INSTANA_AGENT_TOKEN="...Token from invitation email..."
export INSTANA_AGENT_BACKEND="ingress-green-saas.instana.io:443"
```

- Ensure you are logged to AWS.

```bash
aws configure
```

## Usage

```bash

# deploys Instana configuration

# requires the API and Agent token/endpoints
export INSTANA_API_TOKEN="...Instana API token...."
export INSTANA_ENDPOINT="<org>>-<tenant>.instana.io"
export INSTANA_AGENT_TOKEN="...Token from invitation email..."
export INSTANA_AGENT_BACKEND="ingress-green-saas.instana.io:443"
make run ENV=dev MODE=apply

# show Terraform state
make show-state ENV=dev
```

## Day 2

```bash
# check whethe Instana agent connects successfully to backend, SystemD logs are empty
sudo grep "onnected using" /opt/instana/agent/data/log/agent.log


# check Instana agent configuration for backend connectivity
sudo cat /opt/instana/agent/etc/instana/com.instana.agent.main.sender.Backend.cfg

# main Instana Agent configuration file
sudo cat /opt/instana/agent/etc/instana/com.instana.agent.main.config.Agent.cfg
