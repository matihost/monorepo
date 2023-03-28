include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module/ghost")}///"
}

inputs = {
  env = "prod"
  ha = false
  name = "droneshuttles"
  url = "http://ghost.mooo.com"
  instances = [
    { region = "us-central1", image = "ghost:latest" },
    { region = "us-west1", image = "ghost:latest" },
  ]
}
