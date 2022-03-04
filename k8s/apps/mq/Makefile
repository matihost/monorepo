MQ_NAME := dev1
CN := webconsole.$(MQ_NAME).mq.learning.testing.minikube

PERSISTENCE := false
DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := --dry-run --debug
endif

MQ_NAME_UPPER := $(shell echo '$(MQ_NAME)' | tr '[:lower:]' '[:upper:]')


deploy-on-minikube: ## deploy MQ manager;usage: make deploy-on-minikube MQ_NAME=dev1 [DEBUG=false] [PERSISTENCE=false]
	helm upgrade $(DEBUG_FLAG) --install $(MQ_NAME) . -n learning --create-namespace \
		--set mq.persistence.enabled=$(PERSISTENCE) \
    --set webconsole.istio.hostSuffix="testing.minikube" \
    --set webconsole.istio.enabled=true

	@INGRESS_IP="$(shell kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status..ip}")" && \
  [ "$$(grep -c "${INGRESS_IP} $(CN)" /etc/hosts)" -eq 0 ] && echo "/etc/hosts updated with MQ webconsole DNS mapping: $(CN)" && sudo -E sh -c "echo \"$${INGRESS_IP} $(CN)\" >> /etc/hosts" || echo "/etc/hosts already updated with DNS mapping: $(CN)"

undeploy: ## undeploy MQ manager;  make undeploy MQ_NAME=dev1
	helm uninstall $(MQ_NAME) -n learning

test-minikube: ## smoke test for MQ web server; usage: make test-minikube MQ_NAME=dev1
	curl -ksSL https://$(CN)

test-default-queues: ## run sample MQ put and get apps against default queues in the image
	@$(MAKE) test-queues CHANNEL=DEV.APP.SVRCONN QUEUE=DEV.QUEUE.1

test-custom-queues: ## run sample MQ put and get apps against custom queues
	@$(MAKE) test-queues CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB

test-queues: ## run sample MQ put and get apps against queue; press enter for password, usage: make test-queues CHANNEL=APPA.SVRCONN QUEUE=APPA.RQ.APPB
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
