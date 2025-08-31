MQ_NAME := dev1

K8S := minikube

ifeq ($(strip $(K8S)),gke)
	HOST_SUFFIX := internal.gke.shared1.dev.gcp.testing
else ifeq ($(strip $(K8S)),minikube)
	HOST_SUFFIX := minikube
endif

CN := webconsole.$(MQ_NAME).mq.learning.$(HOST_SUFFIX)
APP_PASS := app

PERSISTENCE := false
TLS := false
DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := --dry-run --debug
endif

MQ_NAME_UPPER := $(shell echo '$(MQ_NAME)' | tr '[:lower:]' '[:upper:]')


deploy: ## deploy MQ manager;usage: make deploy [K8S=minikube] [MQ_NAME=dev1] [APP_PASS=app] [TLS=false] [PERSISTENCE=false] [DEBUG=false]
ifeq ($(strip $(TLS)),true)
	$(MAKE) create-certificate
endif
	helm upgrade $(DEBUG_FLAG) --install $(MQ_NAME) . -n learning --create-namespace \
		--set mq.tls.enabled=$(TLS) \
		--set-file mq.tls.key=target/$(MQ_NAME).key \
		--set-file mq.tls.crt=target/$(MQ_NAME).crt \
		--set mq.persistence.enabled=$(PERSISTENCE) \
		--set webconsole.istio.hostSuffix="$(HOST_SUFFIX)" \
		--set webconsole.istio.enabled=true \
		--set mq.app_pass='$(APP_PASS)'
ifeq ($(strip $(K8S)),gke)
	 echo "MQ webconsole available under https://$(CN)"
else ifeq ($(strip $(K8S)),minikube)
	@INGRESS_IP="$(shell kubectl get svc istio-ingressgateway -n istio-ingress -o jsonpath="{.status..ip}")" && \
  [ "$$(grep -c "${INGRESS_IP} $(CN)" /etc/hosts)" -eq 0 ] && echo "/etc/hosts updated with MQ webconsole DNS mapping: $(CN)" && sudo -E sh -c "echo \"$${INGRESS_IP} $(CN)\" >> /etc/hosts" || echo "/etc/hosts already updated with DNS mapping: $(CN)"
endif


undeploy: ## undeploy MQ manager;  make undeploy [MQ_NAME=dev1]
	helm uninstall $(MQ_NAME) -n learning

runmqsc-via-ccdt: ## open admin console access via CDDT json file with ability to run MQ admin commands
	mkdir -p target && \
	sed 's/$${MQ_NAME_UPPER}/$(MQ_NAME_UPPER)/g' cddt.template.json > target/$(MQ_NAME).cddt.json && \
	sed -i 's/$${MQ_IP}/$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')/g' target/$(MQ_NAME).cddt.json && \
	export MQCCDTURL=file://$(shell pwd)/target/$(MQ_NAME).cddt.json && \
	export MQSERVER && \
	runmqsc -c -u admin -w60 $(MQ_NAME_UPPER)

runmqsc-via-tls: ## open admin console accessed via TLS with ability to run MQ admin commands
	mkdir -p target && \
	sed 's/$${MQ_NAME_UPPER}/$(MQ_NAME_UPPER)/g' cddt.tls.template.json > target/$(MQ_NAME).cddt.json && \
	sed -i 's/$${MQ_IP}/$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')/g' target/$(MQ_NAME).cddt.json && \
	[ -e target/$(MQ_NAME).kdb ] || runmqakm -keydb -create -db target/$(MQ_NAME).kdb -type pkcs12 -expire 1000 -stash -pw default && \
	runmqakm -cert -add -label $(MQ_NAME) -db target/$(MQ_NAME).kdb -stashed -trust enable -file target/$(MQ_NAME).crt && \
	export MQCCDTURL=file://$(shell pwd)/target/$(MQ_NAME).cddt.json && \
	export MQSSLKEYR=$(shell pwd)/target/$(MQ_NAME) && \
	export MQSERVER && \
	runmqsc -c -u admin -w60 $(MQ_NAME_UPPER)

runmqsc: ## open admin console accessed with ability to run MQ admin commands
	MQ_IP="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" && \
	export MQSERVER="ADMIN.SVRCONN/TCP/$${MQ_IP}(1414)" && \
	runmqsc -c -u admin -w60 $(MQ_NAME_UPPER)

get-authen-errors: ## show MQ log with authentication errors (2035 error tracing)
	kubectl exec dev1-mq-0 -n learning -- cat /var/mqm/errors/mqhtpass.json

test-web-dashboard: ## smoke test for MQ web server; usage: make test-web-dashboard [MQ_NAME=dev1]
	curl -ksSL https://$(CN)

test-app-queues: ## run sample MQ put and get apps against app queues; usage: make test-app-queues [MQ_NAME=dev1]
	@$(MAKE) test-queues MQ_NAME=$(MQ_NAME) CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB

test-queues: ## run sample MQ put and get apps against queue; press enter for password, usage: make test-queues [MQ_NAME=dev1] CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB
ifndef CHANNEL
	$(error Env CHANNEL is not defined. Usage make test-queues [MQ_NAME=dev1] CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB
endif
ifndef QUEUE
	$(error Env QUEUE is not defined. Usage make test-queues [MQ_NAME=dev1] CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB
endif
	@MQ_IP="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" && \
	export MQSERVER="$(CHANNEL)/TCP/$${MQ_IP}(1414)" && \
	export MQSAMP_USER_ID='' && \
	cd /opt/mqm/samp/bin && \
	./amqsput $(QUEUE) $(MQ_NAME_UPPER) && \
	./amqsget $(QUEUE) $(MQ_NAME_UPPER)


create-certificate: ## create self-signe certificate with CN being MQ_NAME
	mkdir -p target
	openssl req -x509 -sha256 -subj "/CN=${CN}" -days 365 -out "target/${MQ_NAME}.crt" -newkey rsa:2048 -nodes -keyout "target/${MQ_NAME}.key"



help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
