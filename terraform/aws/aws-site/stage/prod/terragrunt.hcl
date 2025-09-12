locals {
  dns       = "www.yoursite.pl"
  tls_crt   = try(file("~/.tls/${local.dns}/cert.pem"), get_env("TLS_CRT", ""))
  tls_chain = try(file("~/.tls/${local.dns}/chain.pem"), get_env("TLS_CHAIN", ""))
  tls_key   = try(file("~/.tls/${local.dns}/privkey.pem"), get_env("TLS_KEY", ""))
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env  = "prod"
  name = "yoursite-site"
  dns  = local.dns
  # use false to expose only HTTP exposure from S3 directly
  # when true, you has to have TLS certificates present in ~/.tls/DNS directory,
  # run to generate one:
  # make generate-letsencrypt-cert DOMAIn=www.yoursite.pl
  enable_tls = true
  # when you intent to expose HTTP only or you need to create TLS via HTTP method only
  # but if you have already TLS certificate then you can deploy it strait away as HTTPS
  bucket_as_dns = false
  tls_crt       = local.tls_crt
  tls_chain     = local.tls_chain
  tls_key       = local.tls_key
  region        = "us-east-1"
  zone          = "us-east-1a"
  aws_tags = {
    Env    = "prod"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
