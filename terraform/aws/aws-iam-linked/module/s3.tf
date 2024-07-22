# On Linked Account S3 Account blockage for expose pubic facing S3 is lifted off
resource "aws_s3_account_public_access_block" "account" {
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}
