resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}


resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.bucket.id
  key    = "index.html"
  source = "${path.module}/index.html"
  etag   = filemd5("${path.module}/index.html")

  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.bucket.id
  key    = "error.html"
  source = "${path.module}/error.html"
  etag   = filemd5("${path.module}/error.html")

  content_type = "text/html"
}


output "s3_site_url" {
  value = "http://${aws_s3_bucket_website_configuration.website.website_endpoint}"
}
