include {
  path = find_in_parent_folders()
}

terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  env  = "dev"
  name = "matihost-site"
  dns  = "matihost.mooo.com"
  # use false to expose only HTTP exposure from S3 directly
  # when true, you has to have TLS certificates present in ~/.tls/DNS directory,
  # run to generate one:
  # make generate-letsencrypt-cert DOMAIn=www.matihost.pl
  enable_tls = true
  region     = "us-east-1"
  zone       = "us-east-1a"
  aws_tags = {
    Env    = "dev"
    Region = "us-east1"
  }
  zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
