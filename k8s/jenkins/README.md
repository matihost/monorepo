# Jenkins CI

Deployment of Jenkin to K8S

## Running

```bash
Usage: deploy-jenkins.sh -e|--env minikube/gke -p jenkins-admin-password [env]

Deploys Jenkins in 'env'.
Assumes kubectl is logged to 'env' cluster already.

Samples:
# deploy to minikube
deploy-jenkins.sh -e minikube -p password-for-jenkins
or
deploy-jenkins.sh minikube -p password-for-jenkins

# deploy to gke
deploy-jenkins.sh -e gke -p password-for-jenkins
```
  