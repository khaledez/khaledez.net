terraform {
  backend "s3" {
    bucket = "net.khaledez.terraform.backend"
    region = "eu-west-2"
  }
}

provider "aws" {
  region  = "eu-west-2"
  version = "~> 2.53"
}

provider "aws" {
  alias   = "virginia"
  region  = "us-east-1"
  version = "~> 2.53"
}

variable "domain_name" {
  description = "Domain name"
}

variable "dns_zone_domain" {
  description = "DNS zone domain, must end with dot(.)"
  default     = "khaledez.net."
}

variable "environment" {
  description = "Evironment tag of the deployed resources"
  default     = "dev"
}

variable "app_name" {
  description = "Aplication which resources belongs to. (reverse-dns)"
  default     = "net.khaledez.www"
}

variable "cache_ttl" {
  description = "Default time to live for cache data"
  default     = 0
}

locals {
  common_tags = {
    Environment = var.environment
    App         = var.app_name
  }

  domain_parts = split(".", var.domain_name)
  base_domain  = join(".", slice(local.domain_parts, 1, length(local.domain_parts)))
}

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

resource "aws_cloudfront_distribution" "cf_website" {
  origin {
    domain_name = aws_s3_bucket.s3_website.bucket_regional_domain_name
    origin_id   = var.domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  aliases    = [var.domain_name]
  depends_on = [aws_acm_certificate_validation.validate_cert]

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

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = var.cache_ttl
    max_ttl                = 86400
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
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    acm_certificate_arn            = aws_acm_certificate.domain_cert.arn
  }
}

data "aws_route53_zone" "primary" {
  name         = var.dns_zone_domain
  private_zone = false
}

resource "aws_route53_record" "www" {
  zone_id         = data.aws_route53_zone.primary.zone_id
  name            = var.domain_name
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cloudfront_distribution.cf_website.domain_name
    zone_id                = aws_cloudfront_distribution.cf_website.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "cert_validation" {
  name    = aws_acm_certificate.domain_cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.domain_cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_route53_zone.primary.id
  records = [aws_acm_certificate.domain_cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate" "domain_cert" {
  provider          = aws.virginia
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags              = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validate_cert" {
  certificate_arn         = aws_acm_certificate.domain_cert.arn
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}

output "domain_name" {
  value = aws_cloudfront_distribution.cf_website.domain_name
}