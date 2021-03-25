# Addons :: Standalone Config Sync

Installs [Standalone Config Sync](https://cloud.google.com/kubernetes-engine/docs/add-on/config-sync/how-to/installing#google-service-account) on GKE

## Prerequisites

* Logged to Google Console Account

* GKE cluster created

## Usage

```bash

# installs Standalone Config Sync on GKE
make apply CLUSTER_NAME=shared1

# unregister GKE from Anthos
make destroy
```
