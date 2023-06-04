# GCP GitHub Workflow Identity Federation

Allow to connect to GCP from GitHub Action with GitHub credentials/token (Identity Federation).
So that GitHub Action can act as GCP Service Account - aka use [google-github-actions/auth](https://github.com/google-github-actions/auth) action in GitHub Workflows.

Creates:

* Workload Identity Provider and Pool to allow exchanging a GitHub Actions OIDC token for a Google Cloud access token.

* GCP ServiceAaccount: `gha-<owner/org>-<repo>` with Workflow Identity Federation which allows GitHub Actions workflows running on behalf of <owner/org>/<repo> repository to impersonate to this GCP Service Account.

* Grants also: GS reader, Artifacts reader and GKE developer roles. So that GitHub Action can use

Warning: Do not attempt to destroy Workload Identity Pool and Providers. They are in fact undeletable and not recreateable.
See the bug: [terraform-provider-google/issues/14805](https://github.com/hashicorp/terraform-provider-google/issues/14805)

```bash
# to login to GCP as human user
make google-authentication

# to create GSA gha-monorepo-matihost with GitHub Identifty Federation
make run MODE=apply GH_REPO=monorepo GH_OWNER=matihost
```
