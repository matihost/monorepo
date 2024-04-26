# Ansible Docker image

Image useful to use as an additional container in K8S Jenkins agent. In principle:

* it runs as user id 1000 (same as inbound-agent/jnlp)
* contains: `ansible` along with `openshift` python modules and kubernetes ansible community bundle (aka `k8s` and `helm` Ansible modules can work)
* `pipenv` - so that image can be used as base Python agent

## Running

Samples:

```bash
# build docker image
make build

# push latest image to quay.io
# assume docker login quay.io has been perfomed
make push

# create additional tag for latest image
make tag TAG=2.16.6

# push image with tag to quay.io
make push TAG=2.16.6
```

## Jenkins CI under GKE

The `k8s/images/ansible/Jenkinsfile` is assumed to work under Jenkins deployed in GKE:

Requirements:

* GKE with Worflow Identytity (aka `terraform/gcp/gke`)

* Jenkins deployed along with this repo Jenkins multibranch pipelines/jobs:

  ```bash
  JENKINS_ADMIN_PASS=choosePass
  cd ../../jenkins && \
    ./deploy-jenkins.sh -e gke -p "${JENKINS_ADMIN_PASS}" && \
    ./ensure-jobs.sh -e gke -p "${JENKINS_ADMIN_PASS}"
  ```

* Workload identity configured for Jenkins `ci` namespaces Kubernetes Service Accounts (KSAs)

  ```bash
  cd ../../../gcp/gke/addons/ns-gke-setup && \
    make run MODE=apply CLUSTER_NAME=shared1 KNS=ci KSAS='["default","ci", "ci-jenkins"]' ROLES='["roles/storage.admin"]'
  ```
