# MQ deployment

MQ deployment under K8S.

Prerequisites:

* Assumes Minikube is installed locally. Deploy MQ server as StatefulSet on Minikube. Use `k8s/minikube` for Minikube deploymnet

* Assumes Istio is deployey on Minikube  for MQ Web Dashboard exposure. Use `k8s/istio` for Istio deployment.

* MQ server listener is exposed via Minikube's LoadBalancer on port 1414.

* Ensure MQ client is installed in the current system. See `ansible/system` playbook for how to install it in Ubuntu. Test tasks uses sample application from MQ client.

* Ensure `app-config.mqsc` contains correct Linux user (currently it is `mati` user) mapped to `app` user on MQ server side. MQ client uses IDPWOS type of authentication - which uses current linux user as authentication method.

## MQ deployment under Minikube

```bash
# deploy MQ manager in Minikube ;usage: make deploy-on-minikube [MQ_NAME=dev1] [DEBUG=false] [PERSISTENCE=false]
make deploy-on-minikube
#  undeploy MQ manager; make undeploy [MQ_NAME=dev1]
make undeploy
#make smoke test for MQ web server; usage: make test-web-dashboard [MQ_NAME=dev1
make test-web-dashboard
```

## Client testing

```bash
# run sample MQ put and get apps against app queues; usage: make test-app-queues [MQ_NAME=dev1]
# warning: just press enter when asked for password, do not type any password
# MQ client uses IDPWOS type of authentication - which uses your linux user name as UserId.
make test-app-queues
make test-queues MQ_NAME=dev1 CHANNEL=APPB.SVRCONN QUEUE=APPB.RS.APPA
```

Or you can do it yourself: (IP is MQ server LoadBalancer)

```bash
source setmqenv -s
export MQSERVER='APPA.SVRCONN/TCP/10.xxx.xxx.xxx(1414)'
export MQSAMP_USER_ID=''
cd /opt/mqm/samp/bin
./amqsput APPA.RQ.APPB DEV1
./amqsget APPA.RQ.APPB DEV1
```
