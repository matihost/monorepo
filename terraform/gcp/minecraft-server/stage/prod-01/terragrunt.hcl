
locals {
  bucket  = "${local.project}-terraform-state"
  project = "${run_cmd("--terragrunt-quiet", "gcloud", "config", "get-value", "project")}"
  zone    = "europe-central2-a"
  region  = "europe-central2"
}


# include does not import locals...
include {
  path = find_in_parent_folders()
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

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
  extra_arguments "common_vars" {
    commands = get_terraform_commands_that_need_vars()

    env_vars = {
      TF_VAR_terraform_state_bucket = local.bucket
    }
  }
}

inputs = {
  project               = local.project
  zone                  = local.zone
  region                = local.region
  vpc                   = "dev-vpc"
  vpc_subnet            = "dev-europe-central2-subnet"
  minecraft_server_name = "prod-01"
  machine_type          = "e2-custom-4-8192" # vs 8cpu & 8GB "e2-highcpu-8"
}
