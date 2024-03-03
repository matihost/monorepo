resource "aws_s3_object" "ingest" {
  bucket = aws_s3_bucket.images.id
  key    = "ingest/"
}

resource "aws_s3_bucket" "images" {
  bucket        = "${local.account_id}-${local.prefix}-images"
  force_destroy = "true"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "images" {
  bucket = aws_s3_bucket.images.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = "true"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cleanup-images" {
  bucket = aws_s3_bucket.images.id

  rule {
    id = "cleanup"

    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }

    expiration {
      days                         = "30"
      expired_object_delete_marker = "false"
    }

    filter {
      prefix = "ingest/"
    }

    status = "Enabled"
  }
}


resource "aws_s3_bucket_notification" "sns-notification" {
  bucket = aws_s3_bucket.images.id

  topic {
    topic_arn     = aws_sns_topic.image-resize.arn
    events        = ["s3:ObjectCreated:*"]
    filter_prefix = "ingest/"
    filter_suffix = ".jpg"
  }
}


output "images_bucket" {
  value = aws_s3_bucket.images.id
}
