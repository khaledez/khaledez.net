terraform {
  required_version = ">= 1.1.0"

  backend "s3" {
    bucket = "net.khaledez.terraform.backend"
    region = "us-east-1"
  }

	required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.71.0"
    }
  }
}

locals {
  common_tags = {
    Environment = var.environment
    App         = var.app_name
  }

  aliases = concat([var.domain_name], var.domain_aliases)
}