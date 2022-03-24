data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "backend" {
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}",
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::427368570714:user/github",
        data.aws_caller_identity.current.arn
      ]
    }
  }
}

resource "aws_s3_bucket" "backend" {
  bucket = var.bucket_name

  tags = {
    Description = "Backend for terraform state"
    Environment = "PROD"
    App         = "net.khaledez.terraform"
  }
}

resource "aws_s3_bucket_policy" "backend" {
  bucket = aws_s3_bucket.backend.id
  policy = data.aws_iam_policy_document.backend.json
}
