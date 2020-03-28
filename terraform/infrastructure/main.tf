provider "aws" {
  region  = "us-east-1"
  version = "~> 2.53"
}

variable "domains" {
  description = "Domains to apply settings for"
  default     = ["khaledez.net", "*.dev.khaledez.net"]
}

variable "domain_aliases" {
  description = "Aliases for domains to be added to the certificate as SAN"
  type        = map(set(string))
  default = {
    "khaledez.net" : ["www.khaledez.net"],
    "*.dev.khaledez.net" : []
  }
}

variable "dns_zone_domain" {
  description = "DNS zone domain, must end with dot(.)"
  default     = "khaledez.net."
}

variable "bucket_name" {
  description = "terraform backend bucket name"
  default     = "net.khaledez.terraform.backend"
}

variable "environment" {
  description = "Evironment tag of the deployed resources"
  default     = "prod"
}

variable "app_name" {
  description = "Aplication which resources belongs to. (reverse-dns)"
  default     = "net.khaledez.www"
}

locals {
  common_tags = {
    Environment = var.environment
    App         = var.app_name
  }
}