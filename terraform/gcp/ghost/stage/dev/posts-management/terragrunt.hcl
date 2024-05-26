# TODO Ghost admin and content keys should be stored in GCP secrets and retrieved during deployment
locals {
  admin_key   = get_env("ADMIN_KEY")
  content_key = get_env("CONTENT_KEY")
}

include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module/posts-management")}///"
}

# some inputs duplication due to https://github.com/gruntwork-io/terragrunt/issues/1566
inputs = {
  env               = "dev"
  name              = "matihost"
  ghost_admin_key   = local.admin_key
  ghost_content_key = local.content_key
}
