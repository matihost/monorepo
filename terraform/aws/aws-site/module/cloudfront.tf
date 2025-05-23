resource "aws_iam_server_certificate" "cert" {
  count = var.enable_tls ? 1 : 0

  name_prefix       = "${local.dns_prefix}-cert-"
  certificate_body  = var.tls_crt
  certificate_chain = var.tls_chain
  private_key       = var.tls_key

  path = "/cloudfront/${replace(var.dns, ".", "")}/"

  lifecycle {
    create_before_destroy = true
  }
}


locals {
  origin_id = aws_s3_bucket.bucket.id
}

data "aws_cloudfront_cache_policy" "policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = var.dns
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "no-override"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distro" {
  count = var.enable_tls ? 1 : 0

  enabled         = true
  staging         = false
  aliases         = toset(concat([var.dns], tolist(var.dns_alternative_names)))
  price_class     = "PriceClass_100"
  http_version    = "http2"
  is_ipv6_enabled = true

  # Necessary for S3 Origins
  default_root_object = "index.html"

  origin {
    origin_id = local.origin_id

    # Expose S3
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id

    # Expose S3 Website endpoint
    # Cannot be used and it does not work with RCP ConfusedDeputy
    #
    # domain_name = aws_s3_bucket_website_configuration.website.website_endpoint
    # custom_origin_config {
    #   http_port              = 80
    #   https_port             = 443
    #   origin_protocol_policy = "http-only"
    #   origin_ssl_protocols   = ["SSLv3", "TLSv1", "TLSv1.1", "TLSv1.2"]
    # }

    connection_attempts = 3
    connection_timeout  = 5
  }
  default_cache_behavior {
    cache_policy_id        = data.aws_cloudfront_cache_policy.policy.id
    allowed_methods        = ["GET", "HEAD"] // "OPTIONS", "PUT", "POST", "PATCH", "DELETE"
    cached_methods         = ["GET", "HEAD"] // "OPTIONS"
    target_origin_id       = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 404
    response_page_path    = "/error.html"
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
