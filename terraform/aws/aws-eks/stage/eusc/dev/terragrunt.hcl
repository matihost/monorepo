include "root" {
  path = find_in_parent_folders("eusc.hcl")
}

locals {
  dd_api_key = try(get_env("DD_API_KEY"), "")
  dd_app_key = try(get_env("DD_APP_KEY"), "")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env      = "dev"
  region   = "eusc-de-east-1"
  zone     = "eusc-de-east-1a"
  vpc_name = "dev-eusc-de-east-1"
  aws_tags = {
    Env    = "dev"
    Region = "eusc-de-east-1"
  }
  zones = ["eusc-de-east-1a", "eusc-de-east-1b",
    # TODO eusc does not have 3 AZs yet
    # "eusc-de-east-1c"
  ]

  install_nginx = true
  # TODO EFS add-on in eusc does not support EKS Pod Identity at this time. Please use IAM roles for service accounts (IRSA) with this add-on.
  install_efs = false
  dd_api_key  = local.dd_api_key
  dd_app_key  = local.dd_app_key

  # Uncomment to integrated cluster authen/authz with OIDC
  # oidc = {
  #   issuer_url     = "https://ServerID/realms/REALM_NAME"
  #   client_id      = "eks"
  #   username_claim = "email"
  #   groups_claim   = "groups"
  # }
  oidc = {
    issuer_url     = "https://id.matihost.pl/realms/id"
    client_id      = "eks"
    username_claim = "email"
    groups_claim   = "groups"
  }

  namespaces = [
    {
      name              = "learning"
      pod_identity_role = "s3all"
      irsa_policy       = "arn:aws-eusc:iam::aws:policy/AmazonS3FullAccess"
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
    # TODO Fargate is not supported
    #  Error: creating EKS Fargate Profile (dev-eusc-de-east-1:dev-eusc-de-east-1-fargate): operation error EKS: CreateFargateProfile,
    #  https response error StatusCode: 400, RequestID: cd02ab1f-f674-4e78-a624-e8c4141812d5,
    #  InvalidRequestException: CreateFargateProfile is not supported for region: eusc-de-east-1
    # {
    #   name    = "learning-fargate"
    #   fargate = true
    #   quota = {
    #     limits = {
    #       cpu    = "8"
    #       memory = "16Gi"
    #     }
    #     requests = {
    #       cpu    = "8"
    #       memory = "16Gi"
    #     }
    #   }
    # }
  ]
}
