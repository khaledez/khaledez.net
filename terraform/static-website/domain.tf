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
    name                   = module.tf_next.cloudfront_domain_name
    zone_id                = module.tf_next.cloudfront_hosted_zone_id
    evaluate_target_health = true
  }
}
