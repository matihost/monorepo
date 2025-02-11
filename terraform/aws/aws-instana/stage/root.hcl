locals {
  bucket                = "${local.account}-terraform-state"
  account               = "${run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "\"Account\"", "--output", "text")}"
  instana_api_token     = get_env("INSTANA_API_TOKEN")
  instana_endpoint      = get_env("INSTANA_ENDPOINT")
  instana_agent_token   = get_env("INSTANA_AGENT_TOKEN")
  instana_agent_backend = get_env("INSTANA_AGENT_BACKEND")
  instana_admin_email   = get_env("INSTANA_ADMIN_EMAIL")
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

provider "instana" {
  # api_token = "secure-api-token", default INSTANA_API_TOKEN env variable
  # endpoint = "<tenant>-<org>.instana.io" # default INSTANA_ENDPOINT
  api_token = "${local.instana_api_token}"
  endpoint = "${local.instana_endpoint}"
  tls_skip_verify     = true
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
  account               = local.account
  instana_token         = local.instana_api_token
  instana_endpoint      = local.instana_endpoint
  instana_agent_token   = local.instana_agent_token
  instana_agent_backend = local.instana_agent_backend
  instana_admin_email   = local.instana_admin_email
}
