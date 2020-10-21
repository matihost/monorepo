# CloudWatch EventRule based trigger for Lambda
resource "aws_cloudwatch_event_rule" "every_one_minute" {
  count               = var.enable_eventrule_lambda_trigger ? 1 : 0
  name                = "every-one-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  count     = var.enable_eventrule_lambda_trigger ? 1 : 0
  rule      = aws_cloudwatch_event_rule.every_one_minute[0].name
  target_id = "lambda"
  arn       = aws_lambda_function.synthetic-ec2-tester.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_lambda" {
  count         = var.enable_eventrule_lambda_trigger ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.synthetic-ec2-tester.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_one_minute[0].arn
}
