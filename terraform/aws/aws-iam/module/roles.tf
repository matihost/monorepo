
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
  description        = "Allow lambda to access VPC resources, S3 objecys, and CloudWatch logs"
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



resource "aws_iam_role" "jenkins-master" {
  name               = "jenkins-master"
  description        = "Should be applied to EC2 with Jenkins Master - so that Jenkins can spawn Jenkins Agent being EC2s"
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

# Only roles exposed as instance_profile can be assigned to EC2
# EC2 instance can obtain the credentials via:
# curl http://169.254.169.254/latest/meta-data/iam/security-credentials/s3all
# AWS CLI inherits them automatically
resource "aws_iam_instance_profile" "jenkins-master" {
  name = "jenkins-master"
  role = aws_iam_role.jenkins-master.name
}

resource "aws_iam_role_policy_attachment" "jenkins-master-s3-attach" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "jenkins-master-ec2-attach" {
  role       = aws_iam_role.jenkins-master.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}



# definining a role to be used by all API Gateways in current region
# the role has to  be able to create CloudWatch log groups for API Gateway logging
# it then can be enabled via:
# resource "aws_api_gateway_account" "apigateway" {
#   cloudwatch_role_arn = aws_iam_role.apigateway-cloudwatch.arn
# }

resource "aws_iam_role" "apigateway-cloudwatch" {
  name = "apigateway-cloudwatch"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "apiGatewayCloudWatchAssignment" {
  role       = aws_iam_role.apigateway-cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
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


resource "aws_iam_role" "read-only" {
  name = "ReadOnly"

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

resource "aws_iam_role_policy_attachment" "read-only-attachment" {
  role       = aws_iam_role.read-only.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}


resource "aws_iam_role" "admin" {
  name = "Admin"

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
