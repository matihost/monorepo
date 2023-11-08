.EXPORT_ALL_VARIABLES:

DEBUG := false
ifeq ($(strip $(DEBUG)),true)
	TF_LOG := DEBUG
endif

MODE := apply
ifeq ($(strip $(MODE)),apply)
	MODE_STR := apply -auto-approve
else ifeq ($(strip $(MODE)),destroy)
	MODE_STR := destroy -auto-approve
else
	MODE_STR := plan
endif


ENV := prod-01

init:
	cd stage/$(ENV) && terragrunt init -upgrade=true


run: init prepare ## setup Minecraft Server VM, usage make run [MODE=plan/apply/destroy] [ENV=prod-01] PASS=pass_for_minecraft_rcon OP_USER=minecraftusername
ifndef ENV
	$(error Environment ENV is not defined. Usage make run ENV=prod MODE=plan [DEBUG=true])
endif
ifndef PASS
	$(error Env PASS is not defined. Provider password for Minecraft rcon is required. Usage make apply PASS=pass_for_minecraft_rcon OP_USER=minecraftusername)
endif
ifndef OP_USER
	$(error Env OP_USER is not defined. Minecraft operator/admin user is required. Usage make apply PASS=pass_for_minecraft_rcon OP_USER=minecraftusername)
endif
	@cd stage/$(ENV) && terragrunt validate && terragrunt $(MODE_STR) -var='server_rcon_pass=$(PASS)' -var='server_op_user=$(OP_USER)'


ssh: ## ssh to Minecraft Server instance
ifndef ENV
	$(error Environment ENV is not defined. Usage make ssh ENV=prod-02
endif
	gcloud compute ssh --strict-host-key-checking=no --zone europe-central2-a `gcloud compute instances list --filter="name~'.*$(ENV)-minecraft-server-.*$$'" --format=json | jq -rc .[0].name`

show-state: ## show terragrunt.state
	cd stage/$(ENV) && terragrunt state list && terragrunt show


google-authentication: ## authenticate to GCP and prepare Application Default Credentials token  (~/.config/gcloud/application_default_credentials.json) for Terraform usage
	gcloud init
	gcloud auth application-default login


clean: ## clean Terraform cached plugins and data
	find . -name ".terra*" -exec rm -rf {} +
	find . -name "target" -exec rm -rf {} +

upgrade-providers-version: init


shutdown: ## resize instance group to zero
	gcloud compute instance-groups managed resize $(ENV)-minecraft-server --zone=europe-central2-a --size=0

bring-up: ## resize instance group to one
	gcloud compute instance-groups managed resize $(ENV)-minecraft-server --zone=europe-central2-a --size=1

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.cloud.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.cloud.vm; }

docs: prepare ## generate html/pdf from *.ad in target directory
	asciidoctor -r asciidoctor-diagram -b html -D target docs/*.ad
	asciidoctor -r asciidoctor-pdf,asciidoctor-diagram -b pdf -D target docs/*.ad

help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
