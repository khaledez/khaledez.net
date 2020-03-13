provider "aws" {
  region = "eu-west-2"
}

variable "bucket_name" {
  description = "backend bucket name"
  default     = "net.khaledez.terraform.backend"
}

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Description = "Backend for terraform state"
    Environment = "PROD"
  }
}