resource "aws_lambda_function" "synthetic-ec2-tester" {
  function_name = var.lambda_function_name
  description   = "Function tests configured IP_TO_TEST http endpoint"
  s3_bucket     = data.terraform_remote_state.lambda-s3.outputs.lambda_bucket
  s3_key        = "lambda/sli-synthetic-client/${var.lambda_version}/sli-synthetic-client.zip"

  source_code_hash = filebase64sha256("build/sli-synthetic-client.zip")
  handler          = "sli-synthetic-client.lambda_handler"
  runtime          = "python3.8"

  role = data.aws_iam_role.lambda-basic.arn

  environment {
    variables = {
      IP_TO_TEST = data.terraform_remote_state.ec2.outputs.ec2_private_dns
    }
  }
  vpc_config {
    subnet_ids         = [data.aws_subnet.public_subnet_1.id]
    security_group_ids = [data.aws_security_group.private_access.id]
  }

  depends_on = [
    aws_cloudwatch_log_group.synthetic-ec2-tester
  ]
}

# this is manage the CloudWatch Log Group for the Lambda Function
resource "aws_cloudwatch_log_group" "synthetic-ec2-tester" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}
