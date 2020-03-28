# Jenkins CI

Deployment of Jenkin to K8S

Playbooks:

* `deploy-jenkins.sh` - deploys Jenkins
* `ensure-job.sh` - ensure Jenkins jobs are present

## Running

Samples:

```bash
# deploy to minikube
deploy-jenkins.sh -e minikube -p password-for-jenkins
or
deploy-jenkins.sh minikube -p password-for-jenkins

# deploy to gke
deploy-jenkins.sh -e gke -p password-for-jenkins

# ensure Jobs for env are present
ensure-jobs.sh -e minikube -p password-for-jenkins
```
