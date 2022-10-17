# resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
#   comment = "Access identity between Cloudfront and S3"
# }

# resource "aws_cloudfront_function" "cf_router" {
#   name    = join("-", [replace(var.domain_name, ".", "-"), "handler"])
#   runtime = "cloudfront-js-1.0"
#   comment = "router function to handle URLs"
#   publish = true
#   code    = file("${path.module}/router.js")
# }

# resource "aws_cloudfront_distribution" "cf_website" {
#   origin {
#     domain_name = aws_s3_bucket.s3_website.bucket_regional_domain_name
#     origin_id   = var.domain_name

#     s3_origin_config {
#       origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
#     }
#   }

#   aliases = local.aliases

#   default_cache_behavior {
#     allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
#     cached_methods   = ["GET", "HEAD"]
#     target_origin_id = var.domain_name

#     forwarded_values {
#       query_string = false

#       cookies {
#         forward = "none"
#       }
#     }

#     function_association {
#       event_type   = "viewer-request"
#       function_arn = aws_cloudfront_function.cf_router.arn
#     }

#     viewer_protocol_policy = "redirect-to-https"
#     min_ttl                = 0
#     default_ttl            = var.cache_ttl
#     max_ttl                = 86400
#     compress               = true

#     response_headers_policy_id = aws_cloudfront_response_headers_policy.headers.id
#   }

#   enabled             = true
#   is_ipv6_enabled     = true
#   default_root_object = "index.html"

#   restrictions {
#     geo_restriction {
#       restriction_type = "none"
#     }
#   }

#   tags = local.common_tags

#   viewer_certificate {
#     ssl_support_method  = "sni-only"
#     acm_certificate_arn = data.aws_acm_certificate.domain_cert.arn
#   }
# }

# resource "aws_cloudfront_response_headers_policy" "headers" {
#   name = join("-", [replace(var.domain_name, ".", "-"), var.environment, "security-custom-headers"])

#   security_headers_config {
#     content_security_policy {
#       override                = true
#       content_security_policy = "default-src *  data: blob: filesystem: about: ws: wss: 'unsafe-inline' 'unsafe-eval'; script-src * 'unsafe-inline' 'unsafe-eval'; connect-src * 'unsafe-inline'; img-src * data: blob: 'unsafe-inline'; frame-src *; style-src * data: blob: 'unsafe-inline'; font-src * data: blob: 'unsafe-inline'"
#     }
#     content_type_options {
#       override = true
#     }
#     referrer_policy {
#       referrer_policy = "strict-origin-when-cross-origin"
#       override        = true
#     }
#     strict_transport_security {
#       access_control_max_age_sec = 31536000
#       override                   = true
#     }
#     frame_options {
#       frame_option = "SAMEORIGIN"
#       override     = true
#     }
#     xss_protection {
#       mode_block = true
#       override   = true
#       protection = true
#     }
#   }
# }
