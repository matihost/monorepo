# Terraform :: ROSA  deployment

Terraform scripts deploy ROSA

In particular it creates:

- ROSA with hosted control planes (HCP): cluster control plane infrastructure hosted in Red Hat-owned AWS account.

## Prerequisites

- The scripts assume that [aws-network-setup](../aws-network-setup) is already deployed (aka private networking is present).

- Latest Terraform or OpenTofu, Terragrunt installed

- ROSA CLI installed:

```bash
[ -x /usr/local/bin/rosa ] || {
  curl -sSL https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz | tar -zx -o rosa
  sudo mv rosa /usr/local/bin/rosa
  rosa version
  sudo rosa completion bash > /etc/bash_completion.d/rosa
}
```

- OC CLI installed (it can be from OKD):

```bash
curl -s https://api.github.com/repos/okd-project/okd/releases/latest | jq -r ".assets[] | select(.browser_download_url | contains(\"openshift-client-linux-4\")) |.browser_download_url" | \
xargs curl -sSL | tar -zx -o oc && sudo mv oc /usr/local/bin
```

- ROSA CLI logged to RedHat:
It will prompt you to open a web browser and go to: [https://console.redhat.com/openshift/token/rosa](https://console.redhat.com/openshift/token/rosa), login and click on the "Load token" button to get the token and copy & paste it to cli invocation:

```bash
rosa login
```

- Logged to AWS Account and ensure Default Region is set.

```bash
aws configure

# or setup default region for your AWS config in case you use AWS secret keys:
[ -e "$HOME/.aws/config" ] || {
  mkdir -p ~/.aws
  echo '[default]
region=us-east-1' > ~/.aws/config
}

# or pass environment variable
export AWS_DEFAULT_REGION=us-east-1
# along with your AWS credentials
export AWS_ACCESS_KEY_ID=....
export AWS_SECRET_ACCESS_KEY=....
export AWS_SESSION_TOKEN=....
```

- Ensure ROSA verification passes:

```bash
make prerequisites
```

- Enable ROSA and linked AWS account with RedHat portal.

Your AWS and Red Hat accounts must be linked so ROSA can provision infrastructure on your AWS account.

For example for us-east-1 region go to [https://us-east-1.console.aws.amazon.com/rosa/home?region=us-east-1#/get-started](https://us-east-1.console.aws.amazon.com/rosa/home?region=us-east-1#/get-started)
Perform prerequistes on this page (like enabling ROSA on AWS account)
and click `Continue to RedHat` to log in into the Red Hat Hybrid Cloud Console and link RedHat and your account.

W/o this you will get error like this - it means that account you mark as billing account is not linked with RedHat portal:
```
Can't create cluster with name 'dev-us-east-1': status is 400, identifier
is '400', code is 'CLUSTERS-MGMT-400', at '2024-11-19T21:21:22Z' and
operation identifier is '24fc9a21-708d-4dd4-a911-878ea16b6ccc': billing
account 666666666666 not linked to organization dummydummydummy
at the aws marketplace
```

## Usage

```bash

# deploys ROSA HCP
make run ENV=dev MODE=apply PASS=cluster-admin-password

# show Terraform state
make show-state

# terminates all AWS resource created with apply task
make run ENV
```

## Day 2 Operations

### Login to cluster via commandline

```bash
# ensure SSH tunnel is opened to tiny-proxy on bastion node - allowing access to private ROSA cluster endpoints
make ensure-proxy-tunnel-open

# login to ROSA cluster
make oc-login ENV=dev

# to run subsequent oc/kubectl commands
# ensure your bash session has proxy enabled:
export HTTPS_PROXY=http://localhost:8888
oc get po -A
k9s
```

### Login to Web Console


Expose PROXY through bastion:

```bash
# ensure SSH tunnel is opened to tiny-proxy on bastion node - allowing access to private ROSA cluster endpoints
make ensure-proxy-tunnel-open

```

Configure your Web browser setting to use [http://localhost:8888](http://localhost:8888) proxy for ROSA/OpenShift endpoints
In case of Google Chrome you may install -Proxy Switcher- extension and apply PAC script on it:

```txt
function FindProxyForURL(url, host) {
  // *.openshiftapps.com endpoints
  if (shExpMatch(host, "*.openshiftapps.com")) {
    return "PROXY localhost:8888";
  }

  # other 10.0.0.0/16 endpoints as well (should match your VPC)
  if (isInNet(host, "10.0.0.0", "255.255.0.0")) {
    return "PROXY localhost:8888";
  }

  // all other requests go DIRECTly
  return "DIRECT";

  // to go through prox, but in case of failure fallback to DIRECT
  // return "PROXY localhost:8888; DIRECT";
}
```

Get Web Console URL endpoint and use it in your web browser:

```bash
make get-web-console-url ENV=dev
```

### Upgrade

TODO test upgrade procedure
[https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/guides/upgrading-hcp-cluster](https://registry.terraform.io/providers/terraform-redhat/rhcs/latest/docs/guides/upgrading-hcp-cluster)
