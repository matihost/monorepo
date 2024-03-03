resource "aws_sqs_queue" "mobileImageResize" {
  content_based_deduplication       = "false"
  delay_seconds                     = "0"
  fifo_queue                        = "false"
  kms_data_key_reuse_period_seconds = "300"
  max_message_size                  = "262144"
  message_retention_seconds         = "345600"
  name                              = "${local.prefix}-ImageResize-RQ-Mobile"

  # policy allowing placing messages to SQS from particular SNS queue
  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": "SQS:*",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-Mobile",
      "Sid": "__owner_statement"
    },
    {
      "Action": "SQS:SendMessage",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-Mobile",
      "Sid": "topic-subscription-arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  receive_wait_time_seconds  = "0"
  sqs_managed_sse_enabled    = "true"
  visibility_timeout_seconds = "30"
}

resource "aws_sqs_queue" "thumbnailImageResize" {
  content_based_deduplication       = "false"
  delay_seconds                     = "0"
  fifo_queue                        = "false"
  kms_data_key_reuse_period_seconds = "300"
  max_message_size                  = "262144"
  message_retention_seconds         = "345600"
  name                              = "${local.prefix}-ImageResize-RQ-ThumbNail"

  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": "SQS:*",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-ThumbNail",
      "Sid": "__owner_statement"
    },
    {
      "Action": "SQS:SendMessage",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-ThumbNail",
      "Sid": "topic-subscription-arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  receive_wait_time_seconds  = "0"
  sqs_managed_sse_enabled    = "true"
  visibility_timeout_seconds = "30"
}

resource "aws_sqs_queue" "webImageResize" {
  content_based_deduplication       = "false"
  delay_seconds                     = "0"
  fifo_queue                        = "false"
  kms_data_key_reuse_period_seconds = "300"
  max_message_size                  = "262144"
  message_retention_seconds         = "345600"
  name                              = "${local.prefix}-ImageResize-RQ-Web"

  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": "SQS:*",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${local.account_id}:root"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-Web",
      "Sid": "__owner_statement"
    },
    {
      "Action": "SQS:SendMessage",
      "Condition": {
        "ArnLike": {
          "aws:SourceArn": "arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sqs:${var.region}:${local.account_id}:${local.prefix}-ImageResize-RQ-Web",
      "Sid": "topic-subscription-arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
    }
  ],
  "Version": "2012-10-17"
}
POLICY

  receive_wait_time_seconds  = "0"
  sqs_managed_sse_enabled    = "true"
  visibility_timeout_seconds = "30"
}
