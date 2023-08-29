locals {
  project = "${run_cmd("--terragrunt-quiet", "gcloud", "config", "get-value", "project")}"
  cn = "id.matihost.mooo.com"
  tls_crt = "${run_cmd("--terragrunt-quiet", find_in_parent_folders("create-selfsigned-tls.sh") , local.cn )}"
  tls_key = file(find_in_parent_folders("target/tls.key"))
}

# include does not import locals...
include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module/keycloak")}///"
}

inputs = {
  env = "prod"
  ha = false
  name = "idp"
  url = "https://${local.cn}"
  welcome_page = "/realms/id/account/#/"
  tls_key = local.tls_key
  tls_crt = local.tls_crt
  instances = [
    { region = "us-central1", image = "us-central1-docker.pkg.dev/${local.project}/docker/keycloak-postgres-cloudsql:latest" },
  ]
}
