locals {
  account = "${run_cmd("--terragrunt-quiet", "sh", "-c", "ibmcloud account show --output json | jq -r .account_id")}"
}


generate "backend" {
  path      = "state.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  backend "local" {
    path = "../../../../target//${local.account}/${path_relative_to_include()}/terraform.tfstate"
  }
}
EOF
}


generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "ibm" {
  region         = var.region
  zone           = var.zone

  # Assuming resource group is created already
  # TODO uncomment when resource group is not ignored
  # https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5108
  # resource_group = var.resource_group_id

  # Do not use public-and-private visibility as it hands with token, use default public
  # visibility = "public-and-private"
}
EOF
}


inputs = {
  account = local.account
}
