include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_admin_password = get_env("CLUSTER_ADMIN_PASS", "")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env      = "dev"
  region   = "us-east-1"
  zone     = "us-east-1a"
  vpc_name = "dev-us-east-1"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  # machine_instance_type     = "c5.2xlarge" # 8 cores, 16 GiB RAM
  enable_cluster_autoscaler = true
  cluster_admin_password    = local.cluster_admin_password

  # openid = {
  #   oidc_name                = "AppName"
  #   issuer_url               = "https://login.microsoftonline.com/...tenantId.../v2.0"
  #   client_id                = "...."
  #   client_secret            = get_env("OIDC_CLIENT_SECRET", "")
  # }
}
