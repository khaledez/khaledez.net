provider "aws" {
  region = "eu-west-2"
}

variable "bucket_name" {
  description = "backend bucket name"
  default     = "net.khaledez.terraform.backend"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = ["arn:aws:s3:::${var.bucket_name}"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::427368570714:user/github",
        "${data.aws_caller_identity.current.arn}"
      ]
    }
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::427368570714:user/github",
        "${data.aws_caller_identity.current.arn}"
      ]
    }
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name
  policy = data.aws_iam_policy_document.terraform_policy.json

  versioning {
    enabled = true
  }

  tags = {
    Description = "Backend for terraform state"
    Environment = "PROD"
    App         = "net.khaledez.terraform"
  }
}