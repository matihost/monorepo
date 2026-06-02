include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env                   = "dev"
  region                = "westeurope"
  zone                  = "westeurope-az1"
  pub_ssh               = try(file("~/.ssh/id_rsa.cloud.vm.pub"), get_env("SSH_PUB", ""))
  ssh_key               = try(file("~/.ssh/id_rsa.cloud.vm"), get_env("SSH_PRIV", ""))
  user_data_template    = file("vm.cloud-init.tpl")
  state_resource_group  = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_rg_name.sh"))}"
  state_storage_account = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_storage_account_name.sh"))}"
  state_container       = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("get_state_container_name.sh"))}"
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  name               = "jump"
  env                = "dev"
  region             = local.region
  zone               = local.zone
  ssh_pub_key        = local.pub_ssh
  ssh_key            = local.ssh_key
  user_data_template = local.user_data_template
  user_data_vars     = [local.state_resource_group, local.state_storage_account, local.state_container]
  spot               = false
  size               = "Standard_B4als_v2" # 4 vcpu, 8 GiB memory

  backup_storage_account_name = local.state_storage_account
  backup_storage_account_rg   = local.state_resource_group


  tags = {
    Environment = "dev"
  }
}
