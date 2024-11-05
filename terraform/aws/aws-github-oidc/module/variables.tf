# tflint-ignore: terraform_unused_declarations
variable "zone" {
  default     = "us-east-1a"
  type        = string
  description = "Preffered AWS AZ where resources need to placed, has to be compatible with region variable"
}

# tflint-ignore: terraform_unused_declarations
variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Preffered AWS region where resource need to be placed"
}


variable "oidc_github_repositories" {
  description = "List of GitHub organization/repository names authorized to assume the role."
  type        = list(string)
  default     = []

  validation {
    # Ensures each element of github_repositories list matches the
    # organization/repository format used by GitHub.
    condition = length([
      for repo in var.oidc_github_repositories : 1
      if length(regexall("^[A-Za-z0-9_.-]+?/([A-Za-z0-9_.:/-]+|\\*)$", repo)) > 0
    ]) == length(var.oidc_github_repositories)
    error_message = "Repositories must be specified in the organization/repository format."
  }
}


variable "oidc_role_name" {
  default     = "github-oidc"
  type        = string
  description = "OIDC role name to be assumed"
}


variable "oidc_role_policies" {
  description = "Policies to attach to OIDC role."
  type        = set(string)
  default     = []
}
