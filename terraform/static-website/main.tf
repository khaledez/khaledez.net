terraform {
  backend "s3" {
    bucket = "net.khaledez.terraform.backend"
    region = "us-east-1"
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

variable "domain_aliases" {
  description = "list of alternative domain names for the same service"
  type        = list(string)
  default     = []
}

variable "cert_domain" {
  description = "ACM domain name"
  default     = "*.dev.khaledez.net"
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

  aliases = concat([var.domain_name], var.domain_aliases)
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

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = var.cache_ttl
    max_ttl                = 86400
    compress               = true
  }

  ordered_cache_behavior {
    target_origin_id       = var.domain_name
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods         = ["GET", "HEAD"]
    path_pattern           = "*"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = var.cache_ttl
    max_ttl     = 86400
    compress    = true

    lambda_function_association {
      event_type = "origin-request"
      lambda_arn = aws_lambda_function.router.qualified_arn
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "/"

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

output "domain_name" {
  value = var.domain_name
}
