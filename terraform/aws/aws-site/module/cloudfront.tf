resource "aws_iam_server_certificate" "cert" {
  count = var.enable_tls ? 1 : 0

  name_prefix       = "${local.dns_prefix}-cert-"
  certificate_body  = file("~/.tls/${var.dns}/cert.pem")
  certificate_chain = file("~/.tls/${var.dns}/chain.pem")
  private_key       = file("~/.tls/${var.dns}/privkey.pem")

  path = "/cloudfront/${replace(var.dns, ".", "")}/"

  lifecycle {
    create_before_destroy = true
  }
}


locals {
  origin_id = aws_s3_bucket.bucket.id
}
resource "aws_cloudfront_distribution" "distro" {
  count = var.enable_tls ? 1 : 0

  enabled         = true
  staging         = false
  aliases         = [var.dns]
  price_class     = "PriceClass_100"
  http_version    = "http2"
  is_ipv6_enabled = true

  origin {
    domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    origin_id   = local.origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    connection_attempts = 3
    connection_timeout  = 5
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"] // "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    cached_methods         = ["GET", "HEAD"] // "OPTIONS"
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "allow-all"
    compress               = true
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    iam_certificate_id             = aws_iam_server_certificate.cert[0].id
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "TLSv1.2_2021"
    cloudfront_default_certificate = false
  }
}


output "cloudfront_domain" {
  value = var.enable_tls ? aws_cloudfront_distribution.distro[0].domain_name : "N/A"
}
