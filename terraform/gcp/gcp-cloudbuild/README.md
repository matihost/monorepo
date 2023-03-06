# GCP Cloud Build

Deploys Cloud Build trigger for GitHub repository

## Prerequisites

* [GCP Network Setup](../gcp-network-setup) terraform has been deployed

* [GitHub Personal Access Token (classic PAT)](https://github.com/settings/tokens) is created for GitHub with at least the following privileges: `read:org, read:user, repo, workflow`.

* [GH CLI](https://github.com/cli/cli#installation) installed

* GH CLI configured with PAT: `gh auth login --with-token`

* [GitHub Google Cloud Build Application](https://github.com/apps/google-cloud-build) installed. After it is installed, go to: [https://github.com/settings/installations/](https://github.com/settings/installations/) and look for Application ID number in the `Configure` button link for Google Cloud Build application. For example: [https://github.com/settings/installations/12312312](https://github.com/settings/installations/12312312). You need this number to assign Cloud Build connection to your GitHub repository.

Warnings:

* If you encounter

```txt
Error: Error creating Repository: googleapi: Error 400: connection must have installation_state COMPLETE (current state: PENDING_INSTALL_APP)
```

it means you either didn't install GitHub Google Cloud Build Application or you provided wrong application id.

## Usage

```bash
# usage: make run CLOUD_BUILD_APP_ID=12312312 [MODE=apply/plan/destroy] [GH_REPO_OWNER=matihost] [GH_REPO_NAME=monorepo]
#
# deploys GCP Cloud Build infrastructure
make run CLOUD_BUILD_APP_ID=12312312

# destroys GCP Cloud Build  infrastructure
make run MODE=destroy CLOUD_BUILD_APP_ID=12312312
```
