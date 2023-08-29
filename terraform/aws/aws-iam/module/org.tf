resource "aws_organizations_organization" "org" {
  enabled_policy_types = ["SERVICE_CONTROL_POLICY", "TAG_POLICY"]
  feature_set          = "ALL"
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
