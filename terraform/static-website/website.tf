resource "aws_s3_bucket" "s3_website" {
  bucket        = var.domain_name
  force_destroy = true

  tags = local.common_tags
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Access identity between Cloudfront and S3"
}

resource "aws_s3_bucket_policy" "s3_website_policy" {
  bucket = aws_s3_bucket.s3_website.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3_website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }

  statement {
    actions   = ["s3:ListBucket"]
    resources = ["${aws_s3_bucket.s3_website.arn}"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn]
    }
  }
}

resource "aws_cloudfront_function" "cf_router" {
  name    = join("-", [replace(var.domain_name, ".", "-"), "handler"])
  runtime = "cloudfront-js-1.0"
  comment = "router function to handle URLs"
  publish = true
  code    = file("${path.module}/router.js")
}

resource "aws_cloudfront_distribution" "cf_website" {
  origin {
    domain_name = aws_s3_bucket.s3_website.bucket_regional_domain_name
    origin_id   = var.domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases = local.aliases

  default_cache_behavior {
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.cf_router.arn
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = var.cache_ttl
    max_ttl                = 86400
    compress               = true
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = local.common_tags

  viewer_certificate {
    ssl_support_method  = "sni-only"
    acm_certificate_arn = data.aws_acm_certificate.domain_cert.arn
  }
}

data "aws_acm_certificate" "domain_cert" {
  provider = aws.virginia
  domain   = var.cert_domain
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "primary" {
  name         = var.dns_zone_domain
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.primary.zone_id

  for_each        = toset(local.aliases)
  name            = each.value
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.cf_website.domain_name
    zone_id                = aws_cloudfront_distribution.cf_website.hosted_zone_id
    evaluate_target_health = true
  }
}
