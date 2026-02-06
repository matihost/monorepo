NS := learning
APP := echoserver
CN := $(APP).$(NS).$(shell kubectl config current-context | cut -d: -f4).dev.aws.testing

k8s:
	@kubectl config current-context | grep -q ":eks:" || { echo "Not logged to EKS cluster"; exit 1; }
	@kubectl config set-context --current --namespace $(NS)


create-cert: k8s ## create TLS CRT to be used by ingress, for simplicity/copy-pasteability it uses CN=* instead of CN being real one
	@kubectl get ns $(NS) >/dev/null 2>&1 || kubectl create ns $(NS)
	@if [ ! -e "/tmp/allcn.key" ]; then \
	  openssl req -x509 -sha256 -nodes -days 365 \
	    -subj "/CN=*" \
	    -newkey rsa:2048 \
	    -keyout "/tmp/all.key" \
	    -out "/tmp/all.crt" >/dev/null 2>&1; \
	fi
	kubectl create secret tls $(APP) \
		--key="/tmp/all.key" \
		--cert="/tmp/all.crt" \
		-n $(NS) --dry-run=client -o yaml | kubectl apply -f -


deploy-via-helm: k8s create-cert ## deploys app via Helm
	helm upgrade --install $(APP) "../.." -n $(NS) --create-namespace \
	  --set ingress.host="$(CN)" \
	  --set ingress.class=nginx

uninstall-helm: k8s ## uninstall
	helm uninstall $(APP) -n $(NS)

deploy-via-script: k8s ## deploys via bash script (kubectl apply)
	./deploy.sh

deploy-via-argocd: k8s create-cert ## deploys via ArgoCD
	kubectl apply -f argocd.yaml -n argocd

test: ## e2e test
	curl -ksSL https://$(CN)

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help
