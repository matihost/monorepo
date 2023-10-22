locals {
  pub_ssh    = file("~/.ssh/id_rsa.aws.vm.pub")
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
}

include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  ssh_pub_key            = local.pub_ssh
  external_access_ip     = local.current_ip
  create_sample_instance = false
}
