MQ_NAME := dev1
CN := webconsole.$(MQ_NAME).mq.learning.testing.minikube

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	DEBUG_FLAG := --dry-run --debug
endif

deploy-on-minikube: ## deploy MQ manager;usage: make deploy-on-minikube MQ_NAME=dev1 [DEBUG=false]
	helm upgrade $(DEBUG_FLAG) --install $(MQ_NAME) . -n learning --create-namespace \
		--set mq.persistence.enabled=true \
    --set webconsole.istio.hostSuffix="testing.minikube" \
    --set webconsole.istio.enabled=true

	@INGRESS_IP="$(shell kubectl get svc istio-ingressgateway -n istio-system -o jsonpath="{.status..ip}")" && \
  [ "$$(grep -c "${INGRESS_IP} $(CN)" /etc/hosts)" -eq 0 ] && echo "/etc/hosts updated with MQ webconsole DNS mapping: $(CN)" && sudo -E sh -c "echo \"$${INGRESS_IP} $(CN)\" >> /etc/hosts" || echo "/etc/hosts already updated with DNS mapping: $(CN)"

undeploy: ## undeploy MQ manager;  make undeploy MQ_NAME=dev1
	helm uninstall $(MQ_NAME) -n learning

test-minikube: ## smoke test for MQ web server; usage: make test-minikube MQ_NAME=dev1
	curl -ksSL https://$(CN)


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
