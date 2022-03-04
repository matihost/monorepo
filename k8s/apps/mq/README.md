# MQ deployment

Sample MQ deployment under K8s

## MQ deployment under Minikube

```bash
# deploy MQ manager;usage: make deploy-on-minikube MQ_NAME=dev1 [DEBUG=false] [PERSISTENCE=false]
make deploy-on-minikube
#  undeploy MQ manager; make undeploy MQ_NAME=dev1
make undeploy
# smoke test for MQ UI web server; usage: make test-minikube MQ_NAME=dev1
make test-minikube
```

## Client testing

Prerequisites:

* Ensure MQ client is installed in the system. See ansible/system playbook for how to install it in Ubuntu.

* Ensure `config.mqsc` contains correct Linux user (currently: mati user) mapped to `app` user on MQ server side.

Then:

```bash
# send message and then receive (scripted)
make test-default-queues
make test-custom-queues
make test-queues CHANNEL=APPB.SVRCONN QUEUE=APPB.RS.APPA
```

Sample send/receive messages for default dev queues:

```bash
# send sample message
source setmqenv -s
export MQSERVER='DEV.APP.SVRCONN/TCP/10.xxx.xxx.xxx(1414)'
# leave empty so that your Linux user is passed for authentication
# leave it also empty when MQ server mq.app_pass helm parameter is empty
# when mq.app_pass is not empty, but your Linux user is mapped to app user on the channel definition (in the sample)
# then you don't need to provided that password as well
# when you change this value it has to repsent an user on MQ server side
export MQSAMP_USER_ID=''
cd /opt/mqm/samp/bin
./amqsputc DEV.QUEUE.1 DEV1
# then to get mesages from queue from mq manager
./amqsgetc DEV.QUEUE.1 DEV
```

Sample send/receive messages for config.mqsc defined queues:

```bash
source setmqenv -s
export MQSERVER='APPA.SVRCONN/TCP/10.xxx.xxx.xxx(1414)'
export MQSAMP_USER_ID=''
cd /opt/mqm/samp/bin
./amqsput APPA.RQ.APPB DEV1
./amqsget APPA.RQ.APPB DEV1
```
