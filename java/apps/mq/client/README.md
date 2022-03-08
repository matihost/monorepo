# Java MQ Client

Sample Java application showing various MQ message exchange patterns:

* send / get  - sends message one way / listening for messages

* sendAndReceive/getAndReply

Prerequisites:

* Sample execution of applications assumes MQ server is deployed on locally deployed. Use `k8s/minikube` and `k8s/istio` for Minikube deployment. Use `k8s\apps\mq` fpr MQ server deployment.

* Sample executions running directly with Java (`make put/get/sendAndReceive/getAndReply`) uses IDPWOS type of authentication with empty userId/pass - which means that MQ client sends current linux user as authentication method. It authenticates successfully when MQ channel has CHLAUTH defined to map linux user to an user on MQ server.

  * Warning: Ensure `app-config.mqsc` in `k8s\apps\mq` contains correct Linux user of your workspace (currently it is `mati` user) mapped to `app` user on MQ server side.

* Sample executions running from container (`make *-container`) uses user `app` for authentication.

## Usage

```bash
# build or build docker image
make build
make build-image

# sample message exchange patterns
#put message on Minikube hosted MQ; usage: make put [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
make put
# put message but run from container
make put-container
# start message listener to receive messages from MQ hosted on Minikube; usage: make get [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
make get
make get-container
# put message on Minikube hosted MQ and awaits for response; usage: make put [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
make sendAndReceive
make sendAndReceive-container
# start message listener to receive messages from MQ and reply to JMSReplyTo queue; usage: make put [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
make getAndReply
make getAndReply-container
```
