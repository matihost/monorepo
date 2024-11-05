resource "aws_iam_openid_connect_provider" "github_actions" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]

  # Note that the thumbprint below has been set to all F's
  # because the thumbprint is not used when authenticating token.actions.githubusercontent.com.
  # This is a special case used only when GitHub's OIDC is authenticating to IAM.
  # IAM uses its library of trusted CAs to authenticate. The value is still the API, so it must be specified.
  thumbprint_list = ["ffffffffffffffffffffffffffffffffffffffff"]
}


resource "aws_iam_role" "oidc_role" {
  name                 = var.oidc_role_name
  description          = "Role assumed by the GitHub OIDC provider."
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.oidc_assume_policy.json

  depends_on = [aws_iam_openid_connect_provider.github_actions]
}


resource "aws_iam_role_policy_attachment" "oidc_role_policy_attachment" {
  for_each = var.oidc_role_policies

  policy_arn = each.key
  role       = aws_iam_role.oidc_role.name
}

data "aws_iam_policy_document" "oidc_assume_policy" {

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test = "StringLike"
      values = [
        for repo in var.oidc_github_repositories :
        "repo:%{if length(regexall(":+", repo)) > 0}${repo}%{else}${repo}:*%{endif}"
      ]
      variable = "token.actions.githubusercontent.com:sub"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type        = "Federated"
    }
  }
}


output "github_oidc_provider_arn" {
  value = aws_iam_openid_connect_provider.github_actions.arn
}

output "oidc_role_arn" {
  value = aws_iam_role.oidc_role.arn
}
