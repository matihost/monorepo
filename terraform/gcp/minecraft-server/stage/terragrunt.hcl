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
