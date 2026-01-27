include "eusc" {
  path = find_in_parent_folders("eusc.hcl")
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  aws_tags = {
    Env = "test"
  }
}
