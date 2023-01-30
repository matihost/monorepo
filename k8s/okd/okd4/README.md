# OKD 4 on GCP

Install OKD 4.x on GCP

Prerequisites:

* GCP Service Account Key file (see `terraform/gcp/gcp-iam` and its `make get-editor-sa-key`)

* GCP Network (see `terraform/gcp/gcp-network-setup`)

Usage:

```bash
# deploys OKD with cluster name and path to GSA key
create-cluster.sh -n okd -k /path/to/gsa/key.json
# or
# create-cluster.sh okd /path/to/gsa/key.json
```
