# Role ami-builder which can be assumed by any user in the account or EC2 instance profiles
resource "aws_iam_role" "amiBuilder" {
  name = "ami-builder"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${local.account_id}"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "amiBuilderPolicyAttachment" {
  role       = aws_iam_role.amiBuilder.name
  policy_arn = aws_iam_policy.amiBuilder.arn
}


resource "aws_iam_role_policy_attachment" "amiBuilderToPassInstanceProfile" {
  role       = aws_iam_role.amiBuilder.name
  policy_arn = aws_iam_policy.passInstanceProfile.arn
}
