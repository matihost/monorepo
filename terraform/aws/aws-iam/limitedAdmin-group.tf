# Admin group will limited admin privilidges
resource "aws_iam_group" "limitedAdmin" {
  name = "LimitedAdmin"
  path = "/"
}

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
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}

# Add API Gateway Admin policy to LimitedAdmin group
resource "aws_iam_group_policy_attachment" "apiGatewayFullAccessToLimitedAdmin" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayAdministrator"
}
