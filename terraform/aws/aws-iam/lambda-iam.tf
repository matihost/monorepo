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

# Add Lambda Admin role to LimitedAdmin
resource "aws_iam_group_policy_attachment" "lambdaFullAccessToLimiteAdmin" {
  group      = aws_iam_group.limitedAdmin.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaFullAccess"
}
