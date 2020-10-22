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
