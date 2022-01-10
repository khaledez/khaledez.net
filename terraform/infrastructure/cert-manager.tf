locals {
  domains_product = merge({ for domain in var.domains : domain => [domain, 0] },
  { for tuple in chunklist(flatten([for key, val in var.domain_aliases : setproduct(val, setproduct([key], range(1, 1 + length(val)))) if length(val) > 0]), 3) : tuple[0] => slice(tuple, 1, 3) })

  domain_alias_map = { for key, val in var.domain_aliases : key => concat([key], tolist(val)) }
}

data "aws_route53_zone" "primary" {
  name         = var.dns_zone_domain
  private_zone = false
}

resource "aws_route53_record" "cert_validation" {
  for_each = local.domains_product
  name     = element(tolist(aws_acm_certificate.domain_cert[each.value[0]].domain_validation_options) ,each.value[1]).resource_record_name
  type     = element(tolist(aws_acm_certificate.domain_cert[each.value[0]].domain_validation_options) ,each.value[1]).resource_record_type
  zone_id  = data.aws_route53_zone.primary.id
  records  = [element(tolist(aws_acm_certificate.domain_cert[each.value[0]].domain_validation_options) ,each.value[1]).resource_record_value]
  ttl      = 60
}

resource "aws_acm_certificate_validation" "validate_cert" {
  for_each                = toset(var.domains)
  certificate_arn         = aws_acm_certificate.domain_cert[each.value].arn
  validation_record_fqdns = [for domain in local.domain_alias_map[each.value] : aws_route53_record.cert_validation[domain].fqdn]
}

resource "aws_acm_certificate" "domain_cert" {
  for_each    = toset(var.domains)
  domain_name = each.value

  subject_alternative_names = var.domain_aliases[each.value]

  validation_method = "DNS"
  tags              = local.common_tags

  lifecycle {
    create_before_destroy = true
  }
}