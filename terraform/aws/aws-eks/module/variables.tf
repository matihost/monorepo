data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = try(data.aws_caller_identity.current.arn, "")
}


locals {
  # tflint-ignore: terraform_unused_declarations
  account_id = data.aws_caller_identity.current.account_id
  prefix     = "${var.name != "" ? "${var.name}-" : ""}${var.env}-${var.region}"
}


variable "name" {
  type        = string
  description = "Name of the cluster"
  default     = ""
}

variable "env" {
  type        = string
  description = "Environment name"
}


# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}


variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}


variable "vpc_name" {
  default     = "dev-us-east-1"
  type        = string
  description = "VPC Name to place EC2 instances"
}


variable "zones" {
  type        = set(string)
  description = "AWS zones for VPC Subnetworks Deployment"
}


variable "cluster_version" {
  type        = string
  default     = "1.31"
  description = "Version of EKS"
  validation {
    condition     = can(regex("^[0-9]*[0-9]+.[0-9]*[0-9]+$", var.cluster_version))
    error_message = "openshift_version must be with structure <major>.<minor> (for example 1.31)."
  }
}

variable "service_cidr" {
  type        = string
  default     = "172.30.0.0/16"
  description = "Block of IP addresses for services, for example \"172.30.0.0/16\"."
}


variable "cluster_admin_arn" {
  type        = string
  default     = null
  description = "The break glass cluster-admin arn, if none provided, the arn of the creator is chosen"
}



variable "namespaces" {
  type = list(object({
    name    = string
    fargate = bool
    quota = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })
  }))

  description = "EKS namespaces configuration"
  default = [{
    name    = "test"
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
  }]
}


variable "oidc" {
  type = object({
    issuer_url     = string
    client_id      = string
    username_claim = string
    groups_claim   = string
  })

  default = null

  description = "EKS OIDC provider configuration"

  # Sample Keycloak config:
  #
  # default = {
  #   issuer = "https://id.matihost.mooo.com/realms/id"
  #   client_id = "eks"
  #   username_claim = "email"
  #   groups_claim = "groups"
  # }
  #
  # Sample token:
  #
  # {
  # "exp": 1734443783,
  # "iat": 1734443483,
  # "auth_time": 1734442743,
  # "jti": "936ace3f-181c-40ca-8bc6-7c7d7093ead8",
  # "iss": "https://id.matihost.mooo.com/realms/id",
  # "aud": "eks",
  # "sub": "f76a1839-abdd-4e1c-9869-b73fa8ed64e8",
  # "typ": "ID",
  # "azp": "eks",
  # "nonce": "ccBdcKskRQZC3LJVfpU-R7pC2mQ03Oz2FQwMxO4C-XY",
  # "sid": "ceb826f0-eed3-4666-8d76-9a95610fa15c",
  # "at_hash": "Djmh28ZTxRYW_bnhO4TIlA",
  # "acr": "0",
  # "email_verified": true,
  # "name": "Name Surname",
  # "groups": [
  #   "/cluster-admins"
  # ],
  # "preferred_username": "name@email.com",
  # "given_name": "Name",
  # "family_name": "Surname",
  # "email": "name@email.com"
  # }
}
