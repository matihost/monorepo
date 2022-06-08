# Istio

Deployment of Istio to Minikube or GKE

Exposes automatically internal Kubernetes API ClusterIp Service via internal Istio ingress gateway.

In case of GKE it solves the [problem](https://cloud.google.com/solutions/creating-kubernetes-engine-private-clusters-with-net-proxies) that GKE Control Plane is not accessible from peered VPC:

  _To access the controller from on-premises or another VPC network, however, requires additional steps. This is because the VPC network that hosts the controller is owned by Google and cannot be accessed from resources connected through another VPC network peering connection, Cloud VPN or Cloud Interconnect._

To access Kubernetes API:

```bash
curl -k -v https://kubernetes.internal.gke.[CLUSTER_NAME].dev.gcp.testing/version
```

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
# Deploys Istio on Minikube (assumes current kubecontext points to Minikube) and CNI is enabled (contained or crio)
make deploy-on-minikube-with-cni
#  Deploys Istio on Minikube on docker w/o CNI
make deploy-on-minikube-on-docker

# undeploys Istio from minikube (assumes current kubecontext points to Minikube)
make undeploy-from-minikube


# Deploys Istio on GKE with standalone NEGs exposed via External Global HTTPS LoadBalancer for external provisioning
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke-neg

# undeploys Istio from GKE with nEGs
make undeploy-from-gke-neg

# Deploys Istio on GKE
# Assumes current kubecontext points to GKE cluster and gcloud context to project where GKE cluster is deployed
make deploy-on-gke

# undeploys Istio from GKE
make undeploy-from-gke
```
