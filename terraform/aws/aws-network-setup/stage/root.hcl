locals {
  bucket  = "${local.account}-terraform-state"
  account = "${run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "\"Account\"", "--output", "text")}"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket = local.bucket
    key    = "${basename(abspath("${get_parent_terragrunt_dir()}/.."))}/${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}/terraform.tfstate"
    region = "us-east-1"
    # TODO play with it... maybe not in free tier
    # encrypt        = true
    # dynamodb_table = "my-lock-table"
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
variable "aws_tags" {
   type = map
}

provider "aws" {
  region  = var.region
  default_tags {
    tags = var.aws_tags
  }
}

provider "aws" {
  for_each = toset(concat([var.region], try(var.vpc_peering_regions, []), try(var.vpc_peering_acceptance_regions, [])))
  alias  = "by_region"
  region = each.key
  default_tags {
    tags = var.aws_tags
  }
}
EOF
}

terraform {
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    env_vars = {
      TF_VAR_terraform_state_bucket = local.bucket
    }
  }
}

inputs = {
  account = local.account
}
