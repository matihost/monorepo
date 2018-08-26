help:
	@echo "Usage: make [ansible-playbook-name.yaml]\n\nFor example: make start-okd-vms.yaml - to start OKD VMs"
	
*.yaml:
	ansible-playbook $@ -v

.PHONY: *.yaml