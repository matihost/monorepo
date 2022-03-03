
.EXPORT_ALL_VARIABLES:

define PV_TEMPLATE
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-$(PVNAME)
  namespace: $(NS)
  labels:
    purpose: MQ
spec:
  capacity:
    storage: 10Gi
  persistentVolumeReclaimPolicy: Recycle
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/tmp/$(PVNAME)"
endef

create-hostPath-pv:  ## creates PV being a dir under /tmp, useful for creating PV for Minikube
ifndef PVNAME
	$(error Env PVNAME is not defined. Usage make apply PVNAME=pvname NS=namespace)
endif
ifndef NS
	$(error Env NS is not defined. Usage make apply PVNAME=pvname NS=namespace)
endif
	@mkdir -p /tmp/$(PVNAME)
	@chmod a+rwx /tmp/$(PVNAME)
	@echo -n "$${PV_TEMPLATE}"| kubectl apply -n $(NS) -f -


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube minikube-test
