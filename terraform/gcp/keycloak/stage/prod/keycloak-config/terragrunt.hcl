locals {
  cn = "id.matihost.mooo.com"

  keycloak_client_id = get_env("KEYCLOAK_CLIENT_ID", "admin-cli")

  # logic to ensure proper Keycloak credentials environment variables are present
  keycloak_secret   = local.keycloak_client_id == "admin-cli" ? get_env("KEYCLOAK_PASSWORD") : get_env("KEYCLOAK_CLIENT_SECRET")
  keycloak_username = local.keycloak_client_id == "admin-cli" ? get_env("KEYCLOAK_USER") : get_env("KEYCLOAK_USER", "")
}

include "root" {
  path = find_in_parent_folders("root.hcl")
}

generate "keycloak-provider" {
  path      = "keycloak-provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "keycloak" {
    #  assuming simple user/password authen
    client_id     = "${local.keycloak_client_id}"

    # username      = "..." # taken from KEYCLOAK_USER env when client_id is admin-cli
    # password      = "..." # taken from KEYCLOAK_PASSWORD env when client_id is admin-cli
    # client_secret = "...." # taken from KEYCLOAK_CLIENT_SECRET when client_id is not admin-cli

    url           = "https://${local.cn}"
    tls_insecure_skip_verify = true
}
EOF
}


terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module/keycloak-config")}///"
}

inputs = {
  env  = "prod"
  name = "idp"
  url  = "https://${local.cn}"

  realm_name = "id"
  # keycloak_users = [
  #   {
  #     email   = "some@email.com"
  #     name    = "Name"
  #     surname = "Surname"
  #   }
  # ]
}
