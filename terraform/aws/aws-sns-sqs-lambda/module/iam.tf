# minimum permission so that lambda can create own /aws/lambda/lambdaname log stream and emit logs
resource "aws_iam_policy" "lambda-basic" {
  name = "AWSLambdaBasicExecutionRole"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": "logs:CreateLogGroup",
      "Effect": "Allow",
      "Resource": "arn:aws:logs::${local.account_id}:*"
    },
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:logs::${local.account_id}:log-group:/aws/lambda/*:*"
      ]
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "s3-editor" {
  name = "AWSLambdaS3EditorExecutionRole"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "s3:*Object"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}

resource "aws_iam_policy" "sqs-poller" {
  name = "AWSLambdaSQSPollerExecutionRole"
  path = "/service-role/"

  policy = <<POLICY
{
  "Statement": [
    {
      "Action": [
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes",
        "sqs:ReceiveMessage"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:sqs:*"
    }
  ],
  "Version": "2012-10-17"
}
POLICY
}


resource "aws_iam_role" "lambdarole" {
  assume_role_policy = <<POLICY
{
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  max_session_duration = "3600"
  name                 = "${var.env}-SQS-S3-LambdaRole"
  path                 = "/service-role/"
}

resource "aws_iam_role_policy_attachment" "lambda-basic" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.lambda-basic.arn
}


resource "aws_iam_role_policy_attachment" "s3-editor" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.s3-editor.arn
}

resource "aws_iam_role_policy_attachment" "sqs-poller" {
  role       = aws_iam_role.lambdarole.name
  policy_arn = aws_iam_policy.sqs-poller.arn
}
