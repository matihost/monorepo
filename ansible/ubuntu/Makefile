help:
	@echo "Usage: make [ansible-playbook-name.yaml]\n\nFor example: make update.yaml - to update Ubuntu packages"
	
*.yaml:
	ansible-playbook $@ -v

.PHONY: *.yaml