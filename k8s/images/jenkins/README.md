# Jenkins Docker image

Jenkins LTS JDK 11 image with pre-downloaded plugins to use with [Jenkins Helm Chart](https://github.com/jenkinsci/helm-charts/blob/main/charts/jenkins/README.md#consider-using-a-custom-image) deployment.

Apart from recommended plugins it contains the following plugins:

* timestamper
* github-branch-source
* matrix-auth
* prometheus
* simple-theme-plugin

## Running

Samples:

```bash
# build docker image
make build

# push lts image to quay.io
# assume docker login quay.io has been perfomed
make push

# create additional tag for lts image
make tag TAG=2.277.4

# push image with tag to quay.io
make push TAG=2.277.4


# run image with bash
make run-bash
```
