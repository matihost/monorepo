provider "aws" {
  region = "us-east-1"
}

resource "random_id" "random" {
  byte_length = 8
}
data "aws_caller_identity" "current" {}

locals {
  lamda_bucket_name = "lambda-bucket-${data.aws_caller_identity.current.account_id}-${random_id.random.hex}"
}


resource "aws_s3_bucket" "lambda" {
  bucket = local.lamda_bucket_name
  acl    = "private"

  force_destroy = true

  tags = {
    Name = local.lamda_bucket_name
  }

  lifecycle_rule {
    id      = "lifetime"
    enabled = true

    # applies to all objects
    # prefix = "log/"

    tags = {
      "rule"      = "lifetime"
      "autoclean" = "true"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # or "ONEZONE_IA"
    }

    # transition {
    #   days          = 60
    #   storage_class = "GLACIER"
    # }

    expiration {
      days = 60
    }
  }
}

output "lambda_bucket" {
  value = aws_s3_bucket.lambda.id
}
