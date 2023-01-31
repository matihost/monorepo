# OKD 4 :: GCP Prerequisites

Creates various GCP objects solely needed by OKD 4 installation :

* create `okd-installer` Service Account with necessary role bindings

* enables Google Services needed to install OKD

## Usage

```bash
# to login to GCP as human user
make google-authentication

# to create IAM objects, in particular SA with okd-installer role
make run

# switch current gcloud configuration to use okd-installer SA
make use-okd-installer-sa

# print okd-installer SA key
make get-okd-installer-sa-key

# store the key in file
mkdir -p target
make get-okd-installer-sa-key > target/key.json
```
