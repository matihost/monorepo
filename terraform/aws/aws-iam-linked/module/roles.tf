
resource "aws_iam_role" "s3all" {
  name = "s3all"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      },
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "pods.eks.amazonaws.com"
        },
        "Action": [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "s3all-attach" {
  role       = aws_iam_role.s3all.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_instance_profile" "s3all" {
  name = "s3all"
  role = aws_iam_role.s3all.name
}

resource "aws_iam_role" "s3reader" {
  name = "s3reader"

  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
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

resource "aws_iam_role_policy_attachment" "s3reader-attach" {
  role       = aws_iam_role.s3reader.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_instance_profile" "s3reader" {
  name = "s3reader"
  role = aws_iam_role.s3reader.name
}


resource "aws_iam_role" "lambda-basic" {
  name               = "lambda-basic"
  description        = "Allow lambda to access VPC resources, S3 objects, and CloudWatch logs"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  }
  EOF
}

# Provides Put, Get access to S3 and full access to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "lambda-basic-lambda-execute" {
  role       = aws_iam_role.lambda-basic.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Provides minimum permissions for a Lambda function to execute while accessing a resource within a VPC - create, describe, delete network interfaces and write permissions to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "lambda-basic-vpc-access" {
  role       = aws_iam_role.lambda-basic.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}





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


# Allowing access from current and management account
# Lack of MFA presence - b/c with SSO it is not present:
# Details:
#  https://repost.aws/questions/QUqgjWSTfJRweHXaD1keQC0A/cross-account-access-not-possible-to-switch-role-when-this-one-has-mfa-enabled
resource "aws_iam_role" "read-only" {
  name = "ReadOnlyAccess"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": [ "${local.account_id}", "${local.org_management_account_id}" ]
            },
            "Action": "sts:AssumeRole"
        },
        {
          "Effect": "Allow",
          "Principal": {
            "Service": "ts.amazonaws.com"
          },
          "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "read-only-attachment" {
  role       = aws_iam_role.read-only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "support-attachment" {
  role       = aws_iam_role.read-only.name
  policy_arn = "arn:aws:iam::aws:policy/AWSSupportAccess"
}

resource "aws_iam_role_policy_attachment" "tools-attachment" {
  role       = aws_iam_role.read-only.name
  policy_arn = aws_iam_policy.tools-access.arn
}


resource "aws_iam_role" "admin" {
  name = "FullAdminAccess"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "${local.account_id}"
            },
            "Action": "sts:AssumeRole",
            "Condition": {
                "Bool": {
                    "aws:MultiFactorAuthPresent": "true"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "admin-attachment" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


resource "aws_iam_role" "default_host_management" {
  name = "DefaultHostManagement"

  assume_role_policy = <<-EOF
  {
      "Version": "2012-10-17",
      "Statement": [
          {
              "Effect": "Allow",
              "Principal": {
                  "Service": "ssm.amazonaws.com"
              },
              "Action": "sts:AssumeRole"
          }
      ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "default_host_management" {
  role       = aws_iam_role.default_host_management.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}


# To connect/ssh to EC2 via SSM
# ECM2 has to be either:
# public facing (be in public subnet)
# or
# it can be private only but it has to have assigned
# instance profile containing minimally AmazonSSMManagedInstanceCore policy
resource "aws_iam_role" "ssm-ec2" {
  name               = "SSM-EC2"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Principal": {"Service": "ec2.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }
}
EOF
}

resource "aws_iam_instance_profile" "ssm-ec2" {
  name = "SSM-EC2"
  role = aws_iam_role.ssm-ec2.name
}


resource "aws_iam_role_policy_attachment" "ssm-ec2" {
  role       = aws_iam_role.ssm-ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
