# MQ deployment

MQ deployment under K8S.

Prerequisites:

* Assumes Minikube or GKE deployment. Deploy MQ server as StatefulSet on Minikube. Use `k8s/minikube` for Minikube deployment

* Assumes Istio is deployed for MQ Web Dashboard exposure. Use `k8s/istio` for Istio deployment.

* MQ server listener is exposed via Service LoadBalancer on port 1414.

* When TLS needed to be used to access queues, TLS option needs to be used during MQ provisioning.

* Ensure MQ client is installed in the current system. See `ansible/system` playbook for how to install it in Ubuntu. It is needed for `runmqsc` cli. Also examples uses sample applications from MQ client.

* MQ client uses IDPWOS type of authentication. It means it uses two ways of authentication methods:

  * When no authentication info is send (aka userId and password is empty) then MQ client sends current linux user as authentication method. It authenticates successfully when MQ channel has CHLAUTH defined to map linux user to an user on MQ server.

    * If you would like to use this method, ensure `app-config.mqsc` contains correct Linux user of your workspace (currently it is `mati` user) mapped to `app` user on MQ server side.

    * Warning: This method is error prone and does not work when MQ client is docker container or K8S pod (as pods run on various linux usernames)

* You pass valid user defined on MQ server and allowed to be used with MQ channel. Currently it is only user `app` with default password: app.

## MQ deployment under Minikube

```bash
# deploy MQ manager on Minikube;usage: make deploy [K8S=minikube] [MQ_NAME=dev1] [APP_PASS=app] [TLS=true] [PERSISTENCE=false] [DEBUG=false]
make deploy

# deploy MQ manager on GKE with TLS;usage: make deploy K8S=gke [MQ_NAME=dev1] [APP_PASS=app] [TLS=true] [PERSISTENCE=false] [DEBUG=false]
make deploy K8S=gke TLS=true

# deploy MQ with custom TLS certificate
make deploy TLS=true

#  undeploy MQ manager; make undeploy [MQ_NAME=dev1]
make undeploy
#make smoke test for MQ web server; usage: make test-web-dashboard [K8S=minikube] [MQ_NAME=dev1]
make test-web-dashboard
```

## Admin tasks

Sample admin commands: [sample-admin-commands.mqsc](sample-admin-commands.mqsc)

```bash
# open admin console access with ability to run MQ admin commands
# when asked, provide admin password (default: default)
make runmqmsc
```

```bash
# open admin console access via CDDT json file with ability to run MQ admin commands
make runmqsc-via-ccdt

# open admin console accessed via TLS with ability to run MQ admin commands
make runmqsc-via-tls
```

```bash
#show MQ log with authentication errors (2035 error tracing)
make get-authen-errors
```

## Client testing

```bash
# run sample MQ put and get apps against app queues; usage: make test-app-queues [MQ_NAME=dev1]
# warning: just press enter when asked for password, do not type any password
# MQ client uses IDPWOS type of authentication - which uses your linux user name as UserId.
# In case you what to authenticate as MQ server user, you need to provider its MQ userId and password
# (currently: app/app)
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
