resource "aws_s3_bucket_website_configuration" "website" {
  count = var.enable_tls ? 0 : 1

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

resource "aws_s3_object" "photo" {
  bucket = aws_s3_bucket.bucket.id
  key    = "matz.jpg"
  source = "${path.module}/matz.jpg"
  etag   = filemd5("${path.module}/matz.jpg")

  content_type = "image/jpeg"
}


resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.bucket.id
  key    = "error.html"
  source = "${path.module}/error.html"
  etag   = filemd5("${path.module}/error.html")

  content_type = "text/html"
}


resource "aws_s3_object" "acme-challenge" {
  bucket = aws_s3_bucket.bucket.id
  key    = ".well-known/acme-challenge/"
}


output "s3_site_url" {
  value = var.enable_tls ? "[N/A]" : "http://${aws_s3_bucket_website_configuration.website[0].website_endpoint}"
}
