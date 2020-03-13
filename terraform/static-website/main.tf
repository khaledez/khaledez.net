terraform {
  backend "s3" {
    bucket = "net.khaledez.terraform.backend"
    region = "eu-west-2"
  }
}

provider "aws" {
  region = "eu-west-2"
  version = "~> 2.53"
}

variable "bucket_name" {
  description = "Bucket name"
}

resource "aws_s3_bucket" "s3_website" {
  bucket = var.bucket_name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}