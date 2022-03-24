terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.6.0"
    }
  }
  required_version = ">= 1.1.0"

  cloud {
    organization = "khaledez"
    workspaces {
      name = "khaledez-net-infra"
    }
  }
}
