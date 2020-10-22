# settings of an API Gateway Account - the settings is applied region-wide per provider block.
# As there is no API method for deleting account settings or resetting it to defaults,
# destroying this resource will keep your account settings intact
resource "aws_api_gateway_account" "apigateway" {
  cloudwatch_role_arn = data.aws_iam_role.apigateway-cloudwatch.arn
}

#
resource "aws_api_gateway_method_settings" "gateway_dp_settings" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  stage_name  = aws_api_gateway_deployment.gateway_dp.stage_name
  method_path = "*/*"
  settings {
    # CloudWatch metrics and traces
    metrics_enabled    = false
    data_trace_enabled = false
    # CloudWatch logs level
    logging_level = "INFO"
    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
  depends_on = [
    aws_cloudwatch_log_group.api_gateway_stage_logs,
    aws_cloudwatch_log_group.api_gateway_welcome_logs
  ]
}


# this is manage the CloudWatch Log Group for the API Gateways
resource "aws_cloudwatch_log_group" "api_gateway_stage_logs" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.gateway.id}/${aws_api_gateway_deployment.gateway_dp.stage_name}"
  retention_in_days = 1
}

resource "aws_cloudwatch_log_group" "api_gateway_welcome_logs" {
  name              = "/aws/apigateway/welcome"
  retention_in_days = 1
}
