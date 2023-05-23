# GitHub Actions Runner Controller v2 :: Autoscaling Runner Scale Sets mode

Deployment of [GitHub Actions Runner Controller](https://github.com/actions/actions-runner-controller) to Minikube or GKE
in [Autoscaling Runner Scale Sets](https://github.com/actions/actions-runner-controller/tree/master/docs/preview/gha-runner-scale-set-controller) mode.

It installs GitHub Arc in [Kubernetes mode](https://github.com/actions/actions-runner-controller/blob/master/docs/deploying-alternative-runners.md#runner-with-k8s-jobs) (DiD or dockerd is disabled).

Limitation:

* inability to have Istio sidecar injection for runner or its workflow pods

Previous version of GitHub Action controller (v1) is provided in v1 directory.

## Prerequisites

* Ansible

```bash
pip3 install --user ansible
pip3 install --user openshift kubernetes
rm -rf ~/.ansible/collections/ansible_collections/kubernetes && \
rm -rf ~/.ansible/collections/ansible_collections/community && \
ansible-galaxy collection install kubernetes.core
ansible-galaxy collection install community.general
```

* Helm

* For GKE: gcloud cli, terraform and GKE itself

* Either GH command configured with Personal Access Token

    or

* GitHub App is used for authentication. Minimal permissions are read access to actions, checks, and metadata and read and write access to administration.
In case  you use GitHub App, you need to create a file in the inventory/\<selected env>/.gh-app.yaml with the GitHub App credentials:

    ```yaml
    github_app_id: ....
    github_app_installation_id: ....
    github_app_private_key: |-
    -----BEGIN R SA PRIVATE KEY-----
    MIIEpQ.....nHBnwKOryeHznDMwwzy0=
    -----END RS A PRIVATE KEY-----
    ```

* Workload identity configured for namespaces where runners are running.
As of now all worker runners are running as `default` KSA.

  ```bash
  cd ../../../gcp/gke/addons/ns-gke-setup && \
    make run MODE=apply CLUSTER_NAME=shared1 KNS=matihost-monorepo-ci KSAS='["default"]' ROLES='["roles/storage.admin"]'
  ```

## Running

```bash
# Deploys  GitHub Actions Runner Controller on Minikube
# Assumes current kubecontext points to Minikube
make deploy-on-minikube
# Deploys  GitHub Actions Runner Controller on GKE using gh command token (PAT)
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke

# Deploys  GitHub Actions Runner Controller on GKE using gh command toke (PAT)
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke

# to undeploy
```
