resource "null_resource" "lambda-package-build" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
	cd ${path.module} && python -m venv target && . ./target/bin/activate && \
	pip install boto3 && cd target/lib/python3*/site-packages && \
	zip -r ../../../../lambda.zip . && cd ../../../.. && \
	zip lambda.zip *.py && rm -rf target && mkdir target && mv lambda.zip target
EOF
  }
}


data "local_file" "lambda-package" {
  filename   = "${path.module}/target/lambda.zip"
  depends_on = [null_resource.lambda-package-build]
}


data "aws_instance" "instance" {
  instance_tags = {
    Name = var.vm_name
  }
}



data "aws_vpc" "default" {
  default = var.vpc == "default" ? true : null

  tags = var.vpc == "default" ? null : {
    Name = var.vpc
  }
}

data "aws_subnet" "public_zone" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = var.zone

  default_for_az = var.subnet == "default" ? true : null

  tags = var.subnet == "default" ? null : {
    Tier = var.subnet
  }
}

resource "aws_iam_role" "synthetic-ec2-tester-lambda" {
  name               = "${local.prefix}-synthetic-ec2-tester-lambda"
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
resource "aws_iam_role_policy_attachment" "lambda-execute" {
  role       = aws_iam_role.synthetic-ec2-tester-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

# Provides minimum permissions for a Lambda function to execute while accessing a resource within a VPC - create, describe, delete network interfaces and write permissions to CloudWatch Logs.
resource "aws_iam_role_policy_attachment" "vpc-access" {
  role       = aws_iam_role.synthetic-ec2-tester-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_lambda_function" "synthetic-ec2-tester" {
  function_name = "${var.env}-${var.lambda_function_name}"
  description   = "Function tests configured IP_TO_TEST http endpoint"

  filename = data.local_file.lambda-package.filename

  source_code_hash = filebase64sha256("${path.module}/sli-synthetic-client.py")
  handler          = "sli-synthetic-client.lambda_handler"
  # https://docs.aws.amazon.com/lambda/latest/dg/lambda-runtimes.html#runtimes-supported
  runtime = "python3.13"

  role = aws_iam_role.synthetic-ec2-tester-lambda.arn

  environment {
    variables = {
      IP_TO_TEST = data.aws_instance.instance.private_dns
    }
  }
  vpc_config {
    subnet_ids         = [data.aws_subnet.public_zone.id]
    security_group_ids = data.aws_instance.instance.vpc_security_group_ids
  }

  depends_on = [
    aws_cloudwatch_log_group.synthetic-ec2-tester,
  ]
}

# this is manage the CloudWatch Log Group for the Lambda Function
resource "aws_cloudwatch_log_group" "synthetic-ec2-tester" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}
