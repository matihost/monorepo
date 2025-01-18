locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env                           = "dev"
  cluster_name                  = "shared1"
  master_cidr                   = "172.16.0.32/28"
  external_access_cidrs         = ["0.0.0.0/0"] # "${local.current_ip}/32"
  expose_master_via_external_ip = true
  encrypt_etcd                  = false
  bigquery_metering             = false
  enable_pod_security_policy    = false
  secondary_ip_range_number     = "0"

  region = "us-central1"
  zone   = "us-central1-a"
}
