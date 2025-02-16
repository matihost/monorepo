include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  env            = "dev"
  region         = "northeurope"
  zone           = "northeurope-az1"
  rh_pull_secret = try(get_env("RH_PULL_SECRET"), file("~/.docker/config.json"))
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env          = local.env
  cluster_name = "shared1"
  region       = local.region
  zone         = local.zone

  master_subnet_suffix = "aro-shared1-master-nodes"
  worker_subnet_suffix = "aro-shared1-worker-nodes"

  rh_pull_secret = local.rh_pull_secret

  oidc = {
    oidc_name      = "id"
    issuer_url     = "https://id.matihost.pl/realms/id"
    client_id      = "aro"
    client_secret  = get_env("OIDC_CLIENT_SECRET")
    username_claim = "preferred_username"
    groups_claim   = "groups"
  }

  namespaces = [
    {
      name = "learning"
      quota = {
        limits = {
          cpu    = "12"
          memory = "16Gi"
        }
        requests = {
          cpu    = "12"
          memory = "16Gi"
        }
      }
    },
    {
      name = "test"
      quota = {
        limits = {
          cpu    = "8"
          memory = "16Gi"
        }
        requests = {
          cpu    = "8"
          memory = "16Gi"
        }
      }
  }]
}
