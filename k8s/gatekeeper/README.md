# OPA Gatekeeper

Deployment of [OPA Gatekeepeer](https://github.com/open-policy-agent/gatekeeper) to Minikube or GKE

Deploys OPA Gatekeeper along with:

* `config` - so that system namespaces are [exempted](https://open-policy-agent.github.io/gatekeeper/website/docs/exempt-namespaces/) from gatekeeping,  and K8S `ns`, `ing` and `vs` objects are [cached within OPA](https://open-policy-agent.github.io/gatekeeper/website/docs/sync) `data.inventory` object.

* deployment of  `constrainttemplates` and `constraints` from [OPA library](https://github.com/open-policy-agent/gatekeeper-library/tree/master/library) to ensure various good practice enforcements( PSP like and general ones)

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

```bash
helm repo add gatekeeper https://open-policy-agent.github.io/gatekeeper/charts
helm repo update
```

* For GKE: gcloud cli, terraform and GKE itself

## Running

```bash
# Deploys OPA Gatekeeper on Minikube
# Assumes current kubecontext points to Minikube
make deploy-on-minikube
# Deploys OPA Gatekeeper on GKE
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke
```
