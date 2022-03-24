locals {
  common_tags = {
    Environment = var.environment
    App         = var.app_name
  }
}

module "acm" {
  source          = "khaledez/acm/aws"
  tags            = local.common_tags
  domains         = var.domains
  domain_aliases  = var.domain_aliases
  route53_zone_id = data.aws_route53_zone.primary.id
}
