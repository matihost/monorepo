deploy-on-minikube-on-docker: ## deploys Istio on Minikube with Docker without CNI enabled (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio.yaml -v -e "{\"cni\": {\"enable\": false}}"

deploy-on-minikube-with-cni: ## deploys Istio on Minikube with CNI deployed (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube deploy-istio.yaml -v

deploy-on-gke: ## deploys Istio on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke deploy-istio.yaml -v

deploy-on-gke-neg: ## deploys Istio on GKE with internal and external ingresses (assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke-neg deploy-istio.yaml -v

undeploy-from-minikube: ## undeploys Istio on Minikube (assumes kubecontext points to Minikube )
	ansible-playbook -i inventory/minikube undeploy-istio.yaml -v

undeploy-from-gke: ## undeploys Istio on GKE with internal ingress only(assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke undeploy-istio.yaml -v

undeploy-from-gke-neg: ## undeploys Istio on GKE with internal and external ingresses (assumes kubecontext points to GKE cluster )
	ansible-playbook -i inventory/gke-neg undeploy-istio.yaml -v

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))

.DEFAULT_GOAL := help
.PHONY: help deploy-on-minikube deploy-on-gke
