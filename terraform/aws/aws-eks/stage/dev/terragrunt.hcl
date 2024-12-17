include {
  path = find_in_parent_folders()
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

  # Uncomment to integrated cluster authen/authz with OIDC
  # oidc = {
  #   issuer_url     = "https://id.yourdomain.com/realms/yourrealm"
  #   client_id      = "eks"
  #   username_claim = "email"
  #   groups_claim   = "groups"
  # }

  namespaces = [{
    name    = "learning"
    fargate = false
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
      name    = "learning-fargate"
      fargate = true
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
