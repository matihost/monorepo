.EXPORT_ALL_VARIABLES:

APP_NAME := basic-client
BASE := quay.io/matihost/mq/$(APP_NAME)
TAG := latest

build: ## build
	mvn -am clean package

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=*:5005
endif

JMX := false
ifeq ($(strip $(JMX)),true)
	JMX_FLAG := -Dcom.sun.management.jmxremote=true -Dcom.sun.management.jmxremote.port=9999 -Dcom.sun.management.jmxremote.local.port=9998 -Dcom.sun.management.jmxremote.rmi.port=9999 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false
endif

MQ_NAME := dev1
MQ_PORT := 1414
MQ_CHANNEL := APPA.SVRCONN
MQ_QUEUE := APPA.RQ.APPB
MQ_QMNAME := $(shell echo '$(MQ_NAME)' | tr '[:lower:]' '[:upper:]')
MQ_TLS := false
ifeq ($(strip $(MQ_TLS)),true)
  MQ_CHANNEL := APPA.TLS.SVRCONN
	TLS_PARAMS := -Djavax.net.ssl.trustStoreType=pkcs12 -Djavax.net.ssl.trustStore=target/$(MQ_NAME).pfx -Djavax.net.ssl.trustStorePassword=default
endif

COMMON_PARAMS := $(DEBUG_FLAG) $(JMX_FLAG) $(TLS_PARAMS) -jar target/*.jar

put: setup-keystore ## put message on Minikube hosted MQ; usage: make put [DEBUG=false MQ_TLS=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	java $(COMMON_PARAMS) --mode=put --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message=alamakota-$(shell date -Is)

get: setup-keystore ## start message listener to receive messages from MQ hosted on Minikube; usage: make get [DEBUG=false MQ_TLS=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	java $(COMMON_PARAMS) --mode=get --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')"

sendAndReceive: setup-keystore ## put message on Minikube hosted MQ and awaits for response; usage: make put [DEBUG=false MQ_TLS=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	java $(COMMON_PARAMS) --mode=sendAndReceive --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message=alamakota-$(shell date -Is) --replyQueue=APPB.RS.APPA

getAndReply: setup-keystore ## start message listener to receive messages from MQ and reply to JMSReplyTo queue; usage: make getAndReply [DEBUG=false MQ_TLS=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	java $(COMMON_PARAMS) --mode=getAndReply --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message=kotmaale-$(shell date -Is)


build-image: build ## build docker image
	DOCKER_BUILDKIT=1 BUILDKIT_PROGRESS=plain docker build --build-arg JAR_FILE=target/*.jar -t $(BASE):$(TAG) .

put-container: ## put message on Minikube hosted MQ; usage: make put-container [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	docker run -it -e MQ_QMNAME -e MQ_PORT -e MQ_CHANNEL -e MQ_QUEUE --rm $(BASE):${TAG} --mode=put --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message='alafromcontainer-$(shell date -Is)' --mq.security.username='app'  --mq.security.password='app'

get-container: ## start message listener to receive messages from MQ hosted on Minikube; usage: make get-container [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	docker run -it -e MQ_QMNAME -e MQ_PORT -e MQ_CHANNEL -e MQ_QUEUE --rm $(BASE):${TAG} --mode=get --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --mq.security.username='app'  --mq.security.password='app'

sendAndReceive-container: ## put message on Minikube hosted MQ; usage: make sendAndReceive-container [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	docker run -it -e MQ_QMNAME -e MQ_PORT -e MQ_CHANNEL -e MQ_QUEUE --rm $(BASE):${TAG} --mode=sendAndReceive --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message=alafromkota-$(shell date -Is) --replyQueue=APPB.RS.APPA --mq.security.username='app'  --mq.security.password='app'

getAndReply-container: ## start message listener to receive messages from MQ and reply to JMSReplyTo queue; usage: make getAndReply-container [DEBUG=false MQ_NAME=dev1 MQ_PORT=1414 MQ_CHANNEL=APPA.SVRCONN MQ_QUEUE=APPA.RQ.APPB]
	docker run -it -e MQ_QMNAME -e MQ_PORT -e MQ_CHANNEL -e MQ_QUEUE --rm $(BASE):${TAG} --mode=getAndReply --mq.host="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" --message=responsefromcontainer-$(shell date -Is)  --mq.security.username='app'  --mq.security.password='app'

push: ## push image with tag to quay.io repository (assume docker login quay.io has been perfomed)
	docker push $(BASE):$(TAG)

setup-keystore: ## setup keystore with tls cert from MQ deployement
ifeq ($(strip $(MQ_TLS)),true)
	@rm -rf target/$(MQ_NAME).pfx
	keytool -keystore target/$(MQ_NAME).pfx -storetype pkcs12 -importcert -file "../../../../k8s/apps/mq/target/$(MQ_NAME).crt" -alias server-certificate -storepass default -noprompt
endif

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help build show-dependencies-updates show-dependency-tree show-effective-pom show-plugins-updates
