resource "aws_organizations_organization" "org" {
  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY", "RESOURCE_CONTROL_POLICY"]
  # In order to Cloud Identity be able to work sso.amazonaws.com has to be explicitly mentioned
  aws_service_access_principals = ["sso.amazonaws.com"]
  feature_set                   = "ALL"
}


resource "aws_organizations_organizational_unit" "shared" {
  name      = "shared"
  parent_id = aws_organizations_organization.org.roots[0].id
  tags = {
    "env" : "shared"
  }
}

resource "aws_organizations_organizational_unit" "dev" {
  name      = "dev"
  parent_id = aws_organizations_organization.org.roots[0].id
  tags = {
    "env" : "dev"
  }
}



resource "aws_organizations_organizational_unit" "prod" {
  name      = "prod"
  parent_id = aws_organizations_organization.org.roots[0].id
  tags = {
    "env" : "prod"
  }
}


data "aws_iam_policy_document" "free-tier-ec2-only" {
  statement {
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]
    condition {
      test     = "StringNotEquals"
      variable = "ec2:InstanceType"
      values   = ["t2.micro", "t3.micro", "t4g.small"]
    }
  }
}

resource "aws_organizations_policy" "free-tier-ec2-only" {
  name    = "free-tier-ec2-only"
  content = data.aws_iam_policy_document.free-tier-ec2-only.json
  type    = "SERVICE_CONTROL_POLICY"
}

# Apply on root so all children org units/account inherits
# By default root org has FullAWSAccess so to limit access it needs adding Deny policies
# Managed account is not affected by any policy constraint
resource "aws_organizations_policy_attachment" "free-tier-ec2-only" {
  policy_id = aws_organizations_policy.free-tier-ec2-only.id
  target_id = aws_organizations_organization.org.roots[0].id
}



# https://docs.aws.amazon.com/IAM/latest/UserGuide/confused-deputy.html
# https://github.com/aws-samples/data-perimeter-policy-examples/tree/main/resource_control_policies/resource_based_policies
data "aws_iam_policy_document" "confused-deputy-protection" {
  statement {
    effect = "Deny"

    sid = "EnforceIdentityPerimeter"

    # RCP does not support * for actions
    # You need to explicitly list
    # https://docs.aws.amazon.com/organizations/latest/userguide/orgs_manage_policies_rcps.html#rcp-supported-services
    actions = [
      "s3:*",
      "sqs:*",
      "kms:*",
      "secretsmanager:*",
      "sts:*"
    ]

    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:PrincipalOrgID"

      values = [
        aws_organizations_organization.org.id
      ]
    }


    condition {
      test     = "BoolIfExists"
      variable = "aws:PrincipalIsAWSService"

      values = [
        "false"
      ]
    }
  }
  statement {
    effect = "Deny"

    sid = "EnforceConfusedDeputyProtection"

    actions = [
      "s3:*",
      "sqs:*",
      "kms:*",
      "secretsmanager:*",
      "sts:*"
    ]

    resources = ["*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "StringNotEqualsIfExists"
      variable = "aws:SourceOrgID"

      values = [
        aws_organizations_organization.org.id
      ]
    }

    condition {
      test     = "Null"
      variable = "aws:SourceAccount"

      values = [
        "false"
      ]
    }

    condition {
      test     = "Bool"
      variable = "aws:PrincipalIsAWSService"

      values = [
        "true"
      ]
    }
  }
}

resource "aws_organizations_policy" "confused-deputy-protection" {
  name    = "EnforceConfusedDeputyProtection"
  content = data.aws_iam_policy_document.confused-deputy-protection.minified_json
  type    = "RESOURCE_CONTROL_POLICY"
}

resource "aws_organizations_policy_attachment" "confused-deputy-protection" {
  policy_id = aws_organizations_policy.confused-deputy-protection.id
  target_id = aws_organizations_organization.org.roots[0].id
}
