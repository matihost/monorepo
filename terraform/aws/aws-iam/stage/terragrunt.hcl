locals {
  bucket = "${local.account}-terraform-state"
  account = "${run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "\"Account\"", "--output", "text")}"
  region = "${get_env("AWS_REGION", "us-east-1")}"
  zone = "us-east-1a"
}

remote_state {
  backend = "s3"
  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = local.bucket
    key = "${basename(abspath("${get_parent_terragrunt_dir()}/.."))}/${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    # TODO play with it... maybe not in free tier
    # encrypt        = true
    # dynamodb_table = "my-lock-table"
  }
}


generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "aws" {
  region  = var.region
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

inputs ={
  account = local.account
  region = local.region
  zone = local.zone
}
