# IBM Cloud :: RedHat OpenShift Kubernetes Service (ROKS)

Terraform scripts creating:

- Cloud Object Storage

- RedHat OpenShift Kubernetes Service (ROKS) instance

- Log Analysis and Monitoring service instances

- Logdna and sysdig agents installed on OpenShift to integrate with Log Analysis and Monitoring services

TODO:

- add KMS

Warnings:

- cluster creation takes very long (small cluster with 3 worker nodes takes 39 minute to spin), cluster creation consists of many steps, cluster may mean in error state transitively, even when cluster seems ready - it still may create Router Ingress controller for more than 15 minutes, if cluster is not available for longer than 1 h, follow below troubleshooting steps

  ```txt
  ibm_container_vpc_cluster.ocp: Creation complete after 39m25s [id=cn2hfqcf0lo791ho1jj0]
  ```

- each addon also takes 5-10 minutes per each, there are 5 addons being installed in this repo

## Cluster troubleshooting steps

```bash
# to check cluster status
ibmcloud ks cluster get --cluster CLUSTER_NAME [--endpoint private]

# to check whether LB for router is created
ibmcloud is load-balancers

# to check cluster nodes status
ibmcloud ks worker ls -c CLUSTER_NAME

# to check ingress status
ibmcloud ks ingress status-report get --cluster CLUSTER_NAME

# to get admin .kube context for cluster (endpoint private if connecting from VPC)
ibmcloud ks cluster config -c CLUSTER_NAME --admin [--endpoint private]

# to login as user (endpoint private if connecting from VPC)
ibmcloud ks cluster config -c CLUSTER_NAME [--endpoint private]

# it is also possible to login to ROKS with IBM Cloud API Key
oc login -u apikey -p IBMCLOUD_APIKEY [--server=<private_service_endpoint>]

# to check ingress deployment status
kubectl get clusteroperator ingress
kubectl get deployment -n openshift-ingress
kubectl get svc -n openshift-ingress

# to check deployed addons
ibmcloud ks cluster addon ls -c CLUSTER_NAME

# to check available addons versions
ibmcloud ks cluster addon versions
```

## Prerequisites

- IBM Cloud CLI installed along with VPC Infrastructure plugin

```bash
# to install https://github.com/IBM-Cloud/ibm-cloud-cli-release for Linux

curl -fsSL "https://clis.cloud.ibm.com/install/$([[ "$(uname -a)" == "Darmin"* ]] && echo "osx" || echo "linux" )" | sh

# list available ibmcloud CLI plugins
ibmcloud plugin repo-plugins

# install ibmcloud plugin for "is" and "ks" commands
ibmcloud plugin install is -f
ibmcloud plugin install ks -f

# to later update cli and all plugins
ibmcloud update
ibmcloud plugin update --all
```

- Logged to IBM Cloud CLI and generated IBM Cloud API key

```bash
# login to IBM SSO, provide default region, for example: eu-de
make ibm-authentication
```

- Latest Docker, OpenTofu, Terragrunt, jq, make, oc, kubectl, helm, k9s (optionally) installed

```bash
# for Mac
brew install opentofu terragrunt jq make openshift-cli kubectl helm k9s
```

- The scripts assume that [ibm-network-setup](../ibm-network-setup) is already deployed (aka private networking is present).

## Usage

```bash
# setup OCP cluster
make run ENV=dev MODE=apply

# ssh to bastion instance
make ssh

# show Terraform state
make show-state

# terminates all resource created with run apply task
make destroy
```
