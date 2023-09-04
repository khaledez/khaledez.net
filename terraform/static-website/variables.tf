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
  default     = "*.preview.khaledez.net"
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
