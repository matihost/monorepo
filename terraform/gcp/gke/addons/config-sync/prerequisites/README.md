# Addons :: Standalone Config Sync :: Prerequisites

GCP resources shared among all GKE clusters with [Standalone Config Sync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/installing#google-service-account) within same GCP project.
It includes:

* GCP Source Repository `gke-configuration`
* GCP SA `gke-config-sync-sa`  which is used by ConfigSync KSA workflow in GKE

## Prerequisites

* Logged to Google Console Account

* GKE cluster created

## Usage

```bash

# installs prerequisites for Standalone Config Sync on GKE
make apply

# unregister GKE from Anthos
make destroy
```
