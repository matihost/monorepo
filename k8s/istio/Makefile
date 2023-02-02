# Istio via Operator

deploy-istio-operator-on-minikube-on-docker-wo-cni: ## deploys Istio via Operator on Minikube with Docker without CNI enabled (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio-operator.yaml -v -e "{\"cni\": {\"enable\": false}}"

deploy-istio-operator-on-minikube: ## deploys Istio via Operator on Minikube with CNI deployed (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio-operator.yaml -v

deploy-istio-operator-on-gke: ## deploys Istio via Operator on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke deploy-istio-operator.yaml -v

deploy-istio-operator-on-gke-neg: ## deploys Istio via Operator on GKE with internal and external ingresses (assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke-neg deploy-istio-operator.yaml -v

undeploy-istio-operator-from-minikube: ## undeploys Istio via Operator on Minikube (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube undeploy-istio-operator.yaml -v

undeploy-istio-operator-from-gke: ## undeploys Istio via Operator on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke undeploy-istio-operator.yaml -v

undeploy-istio-operator-from-gke-neg: ## undeploys Istio via Operator on GKE with internal and external ingresses (assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke-neg undeploy-istio-operator.yaml -v

# Istio via Helm

deploy-istio-helm-on-minikube: ## deploys Istio via Helm on Minikube with CNI deployed (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio-helm.yaml -v

deploy-istio-helm-on-gke: ## deploys Istio via Helm on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke deploy-istio-helm.yaml -v

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube deploy-on-gke
