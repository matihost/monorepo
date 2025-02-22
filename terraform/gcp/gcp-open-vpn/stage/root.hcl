locals {
  bucket  = "${local.project}-terraform-state"
  project = "${run_cmd("--terragrunt-quiet", "gcloud", "config", "get-value", "project")}"
  region  = "${run_cmd("--terragrunt-quiet", "gcloud", "config", "get-value", "compute/region")}"
  zone    = "${run_cmd("--terragrunt-quiet", "gcloud", "config", "get-value", "compute/zone")}"
}

remote_state {
  backend = "gcs"

  config = {
    bucket   = local.bucket
    prefix   = "${basename(abspath("${get_parent_terragrunt_dir()}/.."))}/${basename(get_parent_terragrunt_dir())}/${path_relative_to_include()}"
    project  = local.project
    location = local.region
  }

  generate = {
    path      = "state.tf"
    if_exists = "overwrite_terragrunt"
  }
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  region  = var.region
  zone    = var.zone
  project = var.project
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
  project = local.project
  region  = local.region
  zone    = local.zone
}
