# MQ deployment

Sample MQ deployment under K8s

## Local development under Minikube

```bash
# deploy MQ manager;usage: make deploy-on-minikube MQ_NAME=dev1 [DEBUG=false]
make deploy-on-minikube
#  undeploy MQ manager; make undeploy MQ_NAME=dev1
make undeploy
# smoke test for MQ UI web server; usage: make test-minikube MQ_NAME=dev1
make test-minikube
```
