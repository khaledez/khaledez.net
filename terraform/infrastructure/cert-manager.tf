data "aws_route53_zone" "primary" {
  name         = var.dns_zone_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = toset(var.domains)
  name     = aws_acm_certificate.domain_cert[each.value].domain_validation_options.0.resource_record_name
  type     = aws_acm_certificate.domain_cert[each.value].domain_validation_options.0.resource_record_type
  zone_id  = data.aws_route53_zone.primary.id
  records  = [aws_acm_certificate.domain_cert[each.value].domain_validation_options.0.resource_record_value]
  ttl      = 60
}

resource "aws_acm_certificate" "domain_cert" {
  for_each          = toset(var.domains)
  domain_name       = each.value
  validation_method = "DNS"
  tags              = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "validate_cert" {
  for_each                = toset(var.domains)
  certificate_arn         = aws_acm_certificate.domain_cert[each.value].arn
  validation_record_fqdns = [aws_route53_record.cert_validation[each.value].fqdn]
}