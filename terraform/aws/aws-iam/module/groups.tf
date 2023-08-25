# IAM Admin group allow to define priviledges
resource "aws_iam_group" "iamAdmin" {
  name = "IamAdmin"
  path = "/"
}


resource "aws_iam_group_policy_attachment" "iamFullAccessToIamAdminGroup" {
  group      = aws_iam_group.iamAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}

resource "aws_iam_group_policy_attachment" "billingToAdminGroup" {
  group      = aws_iam_group.iamAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/Billing"
}


############################################################################
# IAM User group - only to allow to modify self and assume roles
resource "aws_iam_group" "user" {
  name = "User"
  path = "/"
}


resource "aws_iam_group_policy_attachment" "user2changePass" {
  group      = aws_iam_group.user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_group_policy_attachment" "user2selfManagement" {
  group      = aws_iam_group.user.name
  policy_arn = aws_iam_policy.selfmanagement.arn
}

resource "aws_iam_group_policy_attachment" "user2assumeAllRoles" {
  group      = aws_iam_group.user.name
  policy_arn = aws_iam_policy.assumeRole.arn
}

############################################################################
# IAM LimitedAdmin group -  with limited admin privilidges
resource "aws_iam_group" "limitedAdmin" {
  name = "LimitedAdmin"
  path = "/"
}

# group inline policies
resource "aws_iam_group_policy" "limitedAdminInlinePolicy" {
  name   = "AssumeRole"
  group  = aws_iam_group.limitedAdmin.name
  policy = aws_iam_policy.assumeRole.policy
}

# managed policies attachments
# there is a hard limit of 10 managed policies that can be attached to a group
resource "aws_iam_group_policy_attachment" "billingViewAccess" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = aws_iam_policy.billingViewAccess.arn
}

resource "aws_iam_group_policy_attachment" "createASGAndALB" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = aws_iam_policy.createASGAndALB.arn
}

resource "aws_iam_group_policy_attachment" "decodeAuthorizedMessagesToAdminGroup" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = aws_iam_policy.decodeAuthorizedMessages.arn
}

resource "aws_iam_group_policy_attachment" "passInstanceProfileToAdminGroup" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = aws_iam_policy.passInstanceProfile.arn
}

resource "aws_iam_group_policy_attachment" "thisUserChangePasswordAttachment" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/IAMUserChangePassword"
}

resource "aws_iam_group_policy_attachment" "viewOnlyAccessToAdminGroup" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"
}


resource "aws_iam_group_policy_attachment" "systemAdminPolicyToAdminGroup" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

resource "aws_iam_group_policy_attachment" "networkAdminPolicyToAdminGroup" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/job-function/NetworkAdministrator"
}

# Add Lambda Admin policy to LimitedAdmin group
resource "aws_iam_group_policy_attachment" "lambdaFullAccessToLimiteAdmin" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
}

# Add API Gateway Admin policy to LimitedAdmin group
resource "aws_iam_group_policy_attachment" "apiGatewayFullAccessToLimitedAdmin" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
