# GCP IAM

Creates initial Identity and Access Management resources for a GCP Project.
In particular:

* instanceGroupUpdater - custom Role (used to for scaling instance groups)

* creates SSH key "~/.ssh/id_rsa.cloud.vm" and use it OS Login SSH key for current GCP active user

* create `editor` Service Account with `roles/editor` rolebinding and create GCloud configuration `project-editor-sa` and switch current gcloud configuration to it, so that from now on, service account with limited permission is used for GCloud manipulations

## Usage

```bash
# to login to GCP as human user
make google-authentication

# to create IAM objects, in particular SA with editor role
make run

# swittch current gcloud configuration to use editor SA
make use-editor-sa
```
