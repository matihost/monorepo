help:
	@echo "Usage: make [ansible-playbook name.yaml]\n\nFor example: make deploy.yaml - to deploy current project"
	
*.yaml:
	ansible-playbook $@ -v

.PHONY: *.yaml