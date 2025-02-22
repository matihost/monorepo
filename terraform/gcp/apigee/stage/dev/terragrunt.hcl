locals {
  cn                 = get_env("EXTERNAL_DNS", "api.dev.matihost.mooo.com")
  internal_cn_prefix = "api" # so for dev main internal zone, it will be: "api.dev.gcp.testing" in result
  tls_crt            = try(file("~/.tls/${local.cn}/fullchain.pem"), try(get_env("TLS_CRT"), run_cmd("--terragrunt-quiet", find_in_parent_folders("create-selfsigned-tls.sh"), local.cn)))
  tls_key            = try(file("~/.tls/${local.cn}/privkey.pem"), try(get_env("TLS_KEY"), file(find_in_parent_folders("target/${local.cn}.key"))))
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}

inputs = {
  env                = "dev"
  external_dns       = local.cn
  internal_cn_prefix = local.internal_cn_prefix
  tls_key            = local.tls_key
  tls_crt            = local.tls_crt
  apigee_envs        = ["dev-1", "dev-2"]
  region             = "us-central1"
  zone               = "us-central1-a"

}
