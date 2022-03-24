data "aws_route53_zone" "primary" {
  name         = var.dns_zone_domain
  private_zone = false
}
