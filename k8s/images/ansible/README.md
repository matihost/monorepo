# Ansible Docker image

Image useful to use as an additional container in K8S Jenkins agent. In principle:

* it runs as user id 1000 (same as inbound-agent/jnlp)
* contains: `ansible` along with `kubernetes`, `openshift` python modules and kubernetes ansible community bundle (aka `k8s` and `helm` Ansible modules can work)
* `pipenv` - so that image can be used as base Python agent

## Running

Samples:

```bash
# build docker image
make build

# push image to quay.io
# assume docker login quay.io has been perfomed
make push
```
