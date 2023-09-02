terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }
  }
  required_version = ">= 1.5.0"

  cloud {
    organization = "khaledez"
    workspaces {
      name = "khaledez-net-infra"
    }
  }
}
