# GitHub Actions Runner Controller V1

Deployment of [GitHub Actions Runner Controller](https://github.com/actions/actions-runner-controller) to Minikube or GKE
It uses [Helm deployment model](https://actions-runner-controller.github.io/actions-runner-controller/).

It installs GitHub Arc in [Kubernetes mode](https://github.com/actions/actions-runner-controller/blob/master/docs/deploying-alternative-runners.md#runner-with-k8s-jobs) (DiD or dockerd is disabled).

Limitation:

* [not full control over workflow pod definition](https://github.com/actions/actions-runner-controller/issues/1730)

* inability to have Istio sidecar injection for runner or its workflow pods

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

## Running

```bash
# Deploys  GitHub Actions Runner Controller on Minikube
# Assumes current kubecontext points to Minikube
make deploy-on-minikube
# Deploys  GitHub Actions Runner Controller on GKE
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke
```
