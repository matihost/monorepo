# Addons :: Anthos

Register cluster in Anthos

Uses
[Google Hub Terraform Module](https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/tree/master/modules/hub)
to register GKE in Anthos.

## Prerequisites

* Logged to Google Console Account

* GKE cluster created

## Usage

```bash
# register GKE in Anthos and enable multicluster ingress
./enable-multiclusteringress.sh

# register GKE in Anthos
make apply

# unregister GKE from Anthos
make destroy
```
