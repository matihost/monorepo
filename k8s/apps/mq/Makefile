MQ_NAME := dev1
CN := webconsole.$(MQ_NAME).mq.learning.testing.minikube
APP_PASS := app

PERSISTENCE := false
DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := --dry-run --debug
endif

MQ_NAME_UPPER := $(shell echo '$(MQ_NAME)' | tr '[:lower:]' '[:upper:]')


deploy-on-minikube: ## deploy MQ manager;usage: make deploy-on-minikube [MQ_NAME=dev1] [APP_PASS=app] [PERSISTENCE=false] [DEBUG=false]
	helm upgrade $(DEBUG_FLAG) --install $(MQ_NAME) . -n learning --create-namespace \
		--set mq.persistence.enabled=$(PERSISTENCE) \
    --set webconsole.istio.hostSuffix="testing.minikube" \
    --set webconsole.istio.enabled=true \
		--set mq.app_pass='$(APP_PASS)'

	@INGRESS_IP="$(shell kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status..ip}")" && \
  [ "$$(grep -c "${INGRESS_IP} $(CN)" /etc/hosts)" -eq 0 ] && echo "/etc/hosts updated with MQ webconsole DNS mapping: $(CN)" && sudo -E sh -c "echo \"$${INGRESS_IP} $(CN)\" >> /etc/hosts" || echo "/etc/hosts already updated with DNS mapping: $(CN)"

undeploy: ## undeploy MQ manager;  make undeploy [MQ_NAME=dev1]
	helm uninstall $(MQ_NAME) -n learning

runmqsc: ## open admin console access with ability to run MQ admin commands
	@MQ_IP="$(shell kubectl get svc $(MQ_NAME)-mq -n learning -o jsonpath='{.status..ip}')" && \
	export MQSERVER="ADMIN.SVRCONN/TCP/$${MQ_IP}(1414)" && \
	runmqsc -c $(MQ_NAME_UPPER) -u admin

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

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
