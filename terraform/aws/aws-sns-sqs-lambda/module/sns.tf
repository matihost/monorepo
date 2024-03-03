resource "aws_sns_topic" "image-resize" {
  display_name                             = "Topic for S3 create object events being new pictures to be resized"
  fifo_topic                               = "false"

  name                                     = "${local.prefix}-ImageResize-Topic"

  # default policy allowing any user from account publishing to topic
  # and
  # non default policy allowing s3 to publish events on the topic
  policy = <<POLICY
{
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Action": [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
      ],
      "Condition": {
        "StringEquals": {
          "AWS:SourceOwner": "${local.account_id}"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Resource": "arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic",
      "Sid": "__default_statement_ID"
    },
    {
      "Action": "SNS:Publish",
      "Condition": {
        "StringEquals": {
          "AWS:SourceAccount": "${local.account_id}"
        }
      },
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Resource": "arn:aws:sns:${var.region}:${local.account_id}:${local.prefix}-ImageResize-Topic"
    }
  ],
  "Version": "2008-10-17"
}
POLICY

  tracing_config                   = "PassThrough"
}


resource "aws_sns_topic_subscription" "imageResize2MobileSqs" {
  endpoint             = aws_sqs_queue.mobileImageResize.arn
  protocol             = "sqs"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.image-resize.id
}

resource "aws_sns_topic_subscription" "imageResize2ThumbnailSqs" {
  endpoint             = aws_sqs_queue.thumbnailImageResize.arn
  protocol             = "sqs"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.image-resize.id
}

resource "aws_sns_topic_subscription" "imageResize2WebSqs" {
  endpoint             = aws_sqs_queue.webImageResize.arn
  protocol             = "sqs"
  raw_message_delivery = "false"
  topic_arn            = aws_sns_topic.image-resize.id
}
