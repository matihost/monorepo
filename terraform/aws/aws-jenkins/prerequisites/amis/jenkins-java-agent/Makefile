AMI_NAME := jenkins-java-agent

build: init ## build
	packer build .

build-arm: init ## build
	packer build -var 'ec2_architecture=arm64' -var 'ec2_instance_type=t4g.small' .

list-amis: ## list AMI and accompanied them EBS snapshot
	@aws ec2 describe-images --owners self --filters "Name=name,Values=$(AMI_NAME)*" --query 'sort_by(Images, &CreationDate)[]' | jq -j '.[]|"AMI:"+.ImageId + ",EBS Snapshot:"+(.BlockDeviceMappings[]|select(.Ebs.SnapshotId != null).Ebs.SnapshotId)+"\n"'

clean-amis: ## clean all AMI with prefix of AMI_NAME (default: jenkinsjava-agent) and accompanied them snapshot (assume EBS type AMIs)
	@for ami_snapshot_pair in `aws ec2 describe-images --owners self --filters "Name=name,Values=$(AMI_NAME)*" --query 'sort_by(Images, &CreationDate)[]' | jq -j '.[]|.ImageId + ","+(.BlockDeviceMappings[]|select(.Ebs.SnapshotId != null).Ebs.SnapshotId)+"\n"'` ; do \
    aws ec2 deregister-image --image-id `echo -n $$ami_snapshot_pair |cut -d"," -f1` ; \
		aws ec2 delete-snapshot --snapshot-id `echo -n $$ami_snapshot_pair |cut -d"," -f2` ; \
  done

init: prepare
	packer init .
	packer fmt .

prepare:
	@[ -e "$(HOME)/.ssh/id_rsa.aws.vm" ] || { cd ~/.ssh && ssh-keygen -m PEM -t rsa -N '' -f id_rsa.aws.vm; }


help: ## show usage and tasks (default)
	@eval $$(sed -E -n 's/^([\*\.a-zA-Z0-9_-]+):.*?## (.*)$$/printf "\\033[36m%-30s\\033[0m %s\\n" "\1" "\2" ;/; ta; b; :a p' $(MAKEFILE_LIST))
.DEFAULT_GOAL := help
.PHONY: help apply destroy
