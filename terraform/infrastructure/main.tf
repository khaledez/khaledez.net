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
  dns_zone_domain = var.dns_zone_domain
}
