# Addons :: Config Connector and Workflow Identity setup for GKE Namespace

Configures Worflow Identity and Config Connector for GKE namespace.

It creates:

* GCP SA `cluster-name-k8s-namespace-name-wsa` binds it to provided GCP roles (ROLES). Always adds metricWriter to the role privileges.
* Workflow Identity with GSA to bind Workflow identity bind to povided Kubernetes Namespace (KNS) Service Accounts (KSAS)
* Config Connector Context with GSA to allow create CRD objects in Kubernetes Namespace (KNS) representing GCP resources.

## Prerequisites

* Logged to Google Console Account

* GKE cluster created along with Workflow Identity and Config Connector Addon

## Usage

```bash

# configures Worflow Identity and Config Connector for GKE namespace and its service accounts
make run CLUSTER_NAME=shared1 KNS=sample-istio KSAS='["default","httpbin"]'

# configure Jenkins namespace so that its builds can push images to gcr.io/ownProject
# https://cloud.google.com/container-registry/docs/access-control#permissions_and_roles
make run CLUSTER_NAME=shared1 KNS=ci KSAS='["default","ci", "ci-jenkins"]' ROLES='["roles/storage.admin"]'

# removes GSA and all its GCP roles bindings making ConfigConnector and Workflow Identity disabled for KNS and KSAs
make run CLUSTER_NAME=shared1 KNS=sample-istio KSAS='["default","httpbin"]' MODE=destroy

# configures default KNS and deploys sample storage bucket as CRD
make test
```
