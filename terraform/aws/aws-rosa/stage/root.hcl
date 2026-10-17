locals {
  bucket  = "${local.account}-terraform-state"
  account = "${run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "\"Account\"", "--output", "text")}"
  # to enforce that RHCS_TOKEN is set in the environment
  rhcs_token = get_env("RHCS_TOKEN")
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
