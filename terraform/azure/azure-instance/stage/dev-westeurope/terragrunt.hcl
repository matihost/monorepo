include {
  path = find_in_parent_folders()
}

locals {
  env                = "dev"
  region             = "westeurope"
  zone               = "westeurope-az1"
  pub_ssh            = try(file("~/.ssh/id_rsa.cloud.vm.pub"), get_env("SSH_PUB", ""))
  ssh_key            = try(file("~/.ssh/id_rsa.cloud.vm"), get_env("SSH_PRIV", ""))
  user_data_template = file("vm.cloud-init.tpl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  name               = "vm"
  env                = "dev"
  region             = local.region
  zone               = local.zone
  ssh_pub_key        = local.pub_ssh
  ssh_key            = local.ssh_key
  user_data_template = local.user_data_template
}
