locals {
  current_ip = "${run_cmd("--terragrunt-quiet", "dig", "+short", "myip.opendns.com", "@resolver1.opendns.com")}"

  env          = "dev"
  cluster_name = "shared1"

  external_gateway_cn      = get_env("EXTERNAL_GATEWAY_DNS", "*.gxlb.gke.${local.cluster_name}.${local.env}.gcp.testing")
  external_gateway_tls_crt = try(file("~/.tls/${local.external_gateway_cn}/fullchain.pem"), try(get_env("EXTERNAL_GATEWAY_TLS_CRT"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-selfsigned-tls.sh"), local.external_gateway_cn)))
  external_gateway_tls_key = try(file("~/.tls/${local.external_gateway_cn}/privkey.pem"), try(get_env("EXTERNAL_GATEWAY_TLS_KEY"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-selfsigned-tls.sh"), local.external_gateway_cn, "true")))
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env          = local.env
  cluster_name = local.cluster_name
  external_gateway = {
    cn      = local.external_gateway_cn
    tls_key = local.external_gateway_tls_key
    tls_crt = local.external_gateway_tls_crt
  }
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
