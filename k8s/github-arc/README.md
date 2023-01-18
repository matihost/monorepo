# GitHub Actions Runner Controller

Deployment of [GitHub Actions Runner Controller](https://github.com/actions/actions-runner-controller) to Minikube or GKE

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
