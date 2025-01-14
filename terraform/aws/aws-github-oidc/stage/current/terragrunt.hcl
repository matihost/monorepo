locals {
  account = "${run_cmd("--terragrunt-quiet", "aws", "sts", "get-caller-identity", "--query", "\"Account\"", "--output", "text")}"
}


include "root" {
  path = find_in_parent_folders("root.hcl")
}


terraform {
  # https://github.com/gruntwork-io/terragrunt/issues/1675
  source = "${find_in_parent_folders("module")}///"
}


inputs = {
  oidc_github_repositories = [
    "matihost/monorepo"
  ]

  oidc_role_name = "github-oidc"
  oidc_role_policies = [
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/CloudFrontFullAccess",
    "arn:aws:iam::${local.account}:policy/IAMCertificateFullAccess"
  ]


}
