resource "aws_s3_bucket" "glue-data" {
  bucket =  "${var.env}-glue-data-${local.account_id}"

  force_destroy = true
}
