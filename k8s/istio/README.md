# Istio

Deployment of Istio to Minikube or GKE

## Prerequisites

* Ansible

```bash
pip3 install --user ansible
pip3 install --user openshift kubernetes
rm -rf ~/.ansible/collections/ansible_collections/community && \
ansible-galaxy collection install community.kubernetes
ansible-galaxy collection install community.general
```

* Helm

* For GKE: gcloud cli, terraform and GKE itself

## Running

```bash
# Deploys Istio on Minikube
# Assumes current kubecontext points to Minikube
make deploy-on-minikube


# Deploys Istio on GKE with standalone NEGs for external provisioning
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke-neg

# Deploys Istio on GKE
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke
```
