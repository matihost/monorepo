# TODO Ghost admin and content keys should be stored in GCP secrets and retrieved during deployment
locals {
  gh_repo = get_env("GH_REPO")
  gh_owner = get_env("GH_OWNER")
}


include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


# some inputs duplication due to https://github.com/gruntwork-io/terragrunt/issues/1566
inputs = {
  gh_repo_name = local.gh_repo
  gh_repo_owner = local.gh_owner
}
