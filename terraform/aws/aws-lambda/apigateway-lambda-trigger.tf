# AWS API Gateway exposure of Lambda

# REST API is the container for all of the other API Gateway objects
resource "aws_api_gateway_rest_api" "gateway" {
  name        = "synthetic-ec2-tester"
  description = "API Gateway to synthetic-ec2-tester lambda"
}

# mathing rules - all incoming requests are proxied and match this resource
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part   = "{proxy+}"
}
resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_resource.proxy.id
  http_method   = "ANY"
  authorization = "NONE"
}


# target rule, what to invoke, in here the target is lambda
resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_method.proxy.resource_id
  http_method = aws_api_gateway_method.proxy.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.synthetic-ec2-tester.invoke_arn
}



# Unfortunately the proxy resource cannot match an empty path at the root of the API.
# To handle that, a similar configuration must be applied to the root resource
# that is built in to the REST API object
resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  resource_id   = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method   = "ANY"
  authorization = "NONE"
}
resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_method.proxy_root.resource_id
  http_method = aws_api_gateway_method.proxy_root.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.synthetic-ec2-tester.invoke_arn
}

# actual deployment of Gateway API configuration
resource "aws_api_gateway_deployment" "gateway_dp" {
  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
  ]

  rest_api_id = aws_api_gateway_rest_api.gateway.id
  stage_name  = "test"
}

# any two AWS services have no access to one another, until access is explicitly granted
# allow API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.synthetic-ec2-tester.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"
}

output "base_url" {
  value = aws_api_gateway_deployment.gateway_dp.invoke_url
}
