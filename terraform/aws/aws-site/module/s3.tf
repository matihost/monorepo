resource "aws_s3_bucket" "bucket" {
  bucket              = var.dns
  force_destroy       = "true"
  object_lock_enabled = "false"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_enc" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = "true"
  }
}


resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

# So that policy enabling public access make sense
resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.public_policy.json
}

# WARNING:
# Access to S3 is blocked by RCP ConfusedDeputyProtection which allow only Authenticated access from current Organization
# If you wish that S3 content is exposed via HTTP directly from S3 Website Exposure - ensure RCP does not prevent it.
data "aws_iam_policy_document" "public_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      # s3:ListBucket is to return 404 instead of 403 in case S3 is exposed directly via CloudFront
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}


output "s3_url" {
  value = "https://${aws_s3_bucket.bucket.bucket}.s3.amazonaws.com"
}
