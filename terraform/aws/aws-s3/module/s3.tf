resource "random_id" "id" {
  byte_length = 8
}


resource "aws_s3_bucket" "bucket" {
  bucket              = "${local.prefix}-${random_id.id.hex}"
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

data "aws_iam_policy_document" "public_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      # "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.bucket.arn,
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}


resource "aws_s3_object" "cached-dir" {
  bucket = aws_s3_bucket.bucket.id
  key    = "CachedObjects/"
}


resource "aws_s3_object" "input" {
  bucket  = aws_s3_bucket.bucket.id
  key     = "CachedObjects/input.json"
  content = <<EOF
{"name": "John Doe", "address" : "111 Some Dr 76726282 Irving TX, US", "cc": "4242424242424242"}
{"name": "Anna Doe", "address" : "111 Some Dr 12323453 Irving TX, US", "cc": "5555555555554444"}
EOF
}


output "s3_url_for_input" {
  value = "https://${aws_s3_bucket.bucket.bucket}.s3.amazonaws.com/CachedObjects/input.json"
}
